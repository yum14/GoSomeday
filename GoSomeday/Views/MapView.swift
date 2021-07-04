//
//  MapView.swift
//  GoSomeday
//
//  Created by yum on 2021/04/12.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @Binding var moveCurrentLocation: Bool
    @Binding var moveCoordinateRegion: Bool
    
    var annotations: [PointAnnotation] = []
    var onTapGesture: (CLLocationCoordinate2D, CLPlacemark?) -> Void = { _, _ in }
    
    var animated: Bool = false
    let map = MKMapView(frame: .zero)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        // 現在地が取得できない場合の初期値
//        let center = CLLocationCoordinate2D(latitude: 35.6804, longitude: 139.7690)
//        let region = MKCoordinateRegion(center: center, latitudinalMeters: 200, longitudinalMeters: 200)
//        map.region = region
        
        
        map.region = self.coordinateRegion
        map.addGestureRecognizer(context.coordinator.myTapRecognizer)
        map.showsUserLocation = true
        map.delegate = context.coordinator
        
        manager.delegate = context.coordinator
        manager.startUpdatingLocation()
        manager.requestWhenInUseAuthorization()
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        if self.moveCoordinateRegion {
            uiView.setRegion(coordinateRegion, animated: self.animated)
            self.moveCoordinateRegion.toggle()
        }
        // 削除のために一度全て削除してから追加する
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations.map {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: $0.coordinate?.latitude ?? 0, longitude: $0.coordinate?.longitude ?? 0)
            return annotation
        })
    }
    
    class Coordinator : NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent : MapView
        let myTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()

        init(_ parent : MapView) {
            self.parent = parent
            
            super.init()
            self.myTapRecognizer.addTarget(self, action: #selector(self.recognizeTap))
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                parent.alert.toggle()
                print("denied")
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if self.parent.moveCurrentLocation {
                let location = locations.last
                let region = MKCoordinateRegion(center: location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
                
                self.parent.coordinateRegion = region
                self.parent.map.setRegion(region, animated: true)
                self.parent.moveCurrentLocation.toggle()
//            } else {
//                self.parent.coordinateRegion = self.parent.map.region
            }
        }
        
        @objc func recognizeTap(sender: UITapGestureRecognizer) {
            if sender.state == .ended {
                if let mapView = sender.view as? MKMapView {
                    
                    // タップした位置を取得
                    let point = sender.location(in: mapView)
                    // mapView上での位置に変換
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    let georeader = CLGeocoder()
                    georeader.reverseGeocodeLocation(location) { (places, err) in
                        if err != nil {
                            print((err?.localizedDescription)!)
                            return
                        }
                        
                        let placemark = places?.first
                        self.parent.onTapGesture(coordinate, placemark)
                    }
                }
            }
        }
    }
}

extension CLPlacemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}
