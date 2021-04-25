//
//  HomeViewModel.swift
//  GoSomeday
//
//  Created by yum on 2021/04/17.
//

import Foundation
import MapKit
import PartialSheet

class HomeViewModel: ObservableObject {
    @Published var manager = CLLocationManager()
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.710263046992736, longitude: 139.81067894034084),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    @Published var searchText = "" {
        didSet {
            Search()
        }
    }
    
    @Published var moveCurrentLocation = true
    @Published var moveCoordinateRegion = false
    
    @Published var mapItems: [MapItem] = []
    @Published var annotations: [PointAnnotation] = []
    
    @Published var searching = false
    @Published var resignFirstResponder = false
    @Published var showsCancelButton = false
    
    private let searchModel = LocalSearchModel()
    private let searchHistoryStore = SearchHistoryStore.shared
    private let MaxHistory = 3
    
    func Search() {
        if self.searchText.isEmpty {
            self.mapItems = []
        }
        
        // 検索
        // TODO: regionの範囲の最大値は定義しておく。
        searchModel.search(query: self.searchText, region: self.region, completion: { result in
            switch result {
            case .success(let mapItems):
                self.mapItems = mapItems.map {
                    MapItem(name: $0.name,
                            phoneNumber: $0.phoneNumber,
                            url: $0.url?.absoluteString,
                            placemark: Placemark(
                                coordinate: LocationCoordinate(latitude: $0.placemark.coordinate.latitude,
                                                               longitude: $0.placemark.coordinate.longitude),
                                countryCode: $0.placemark.countryCode,
                                administrativeArea: $0.placemark.administrativeArea,
                                locality: $0.placemark.locality,
                                thoroughfare: $0.placemark.thoroughfare,
                                subThoroughfare: $0.placemark.subThoroughfare)
                    )
                }
                
            case .failure(let error):
                print("error \(error.localizedDescription)")
                self.mapItems = []
            }
        })
    }
    
    func onMapViewTap(coordinate: CLLocationCoordinate2D, placemark: CLPlacemark?) -> PointAnnotation {
    
//        print("\(placemark!.name)")
//        print("\(placemark!.isoCountryCode)")
//        print("\(placemark!.country)")
//        print("\(placemark!.postalCode)")
//        print("\(placemark!.administrativeArea)")
//        print("\(placemark!.subAdministrativeArea)")
//        print("\(placemark!.locality)")
//        print("\(placemark!.subLocality)")
//        print("\(placemark!.thoroughfare)")
//        print("\(placemark!.subThoroughfare)")
//        print("\(placemark!.address)")
        
        let annotation = PointAnnotation(id: UUID().uuidString,
                                         title: nil,
                                         subtitle: placemark?.address,
                                         coordinate: LocationCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        self.annotations.append(annotation)

        // annotationの場所をセンターにする
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.moveCoordinateRegion = true
        
        return annotation
    }
    
    
    func onNewPointViewDismiss(id: String) {
        guard let index = self.annotations.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        self.annotations.remove(at: index)
    }
    
    
    func onSearchResultTap(item: MapItem) -> Void {
        guard let coordinate = item.placemark?.coordinate else {
            return
        }
        self.searchText = item.name ?? ""
        
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        // 検索履歴の追加と削除
        self.addSearchHistory(item)
        
        self.moveCoordinateRegion = true
        self.searching = false
        
        // SearchBarからフォーカスを外す
        self.resignFirstResponder = true
    }
    
    func onSearchBarCommit(item: MapItem) -> Void {
        guard let coordinate = item.placemark?.coordinate else {
            return
        }
        self.searchText = item.name ?? ""
        
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        // 検索履歴の追加と削除
        self.addSearchHistory(item)
        
        self.moveCoordinateRegion = true
        self.searching = false
    }
    
    func onLocationButtonTap() {
        self.moveCurrentLocation = true
    }
    
    func onSearchHistoryListTap(item: MapItem) {
        guard let coordinate = item.placemark?.coordinate else {
            return
        }
        self.searchText = item.name ?? ""
        
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        self.moveCoordinateRegion = true
        self.searching = false
        
        // SearchBarからフォーカスを外す
        self.resignFirstResponder = true
        self.showsCancelButton = false
    }
    
    
    private func addSearchHistory(_ item: MapItem) {
        guard let placemark = item.placemark, let coordinate = placemark.coordinate else {
            return
        }
        
        // 保存する最大値を超える履歴を削除する
        if self.searchHistoryStore.mapItems.count >= self.MaxHistory {
            var counter = 1
            for item in self.searchHistoryStore.mapItems.sorted(by: { $0.order > $1.order }) {
                if counter >= self.MaxHistory {
                    self.searchHistoryStore.delete(id: item.id)
                }
                
                counter += 1
            }
        }
        
        // 検索履歴を追加
        searchHistoryStore.add(MapItem(name: item.name,
                                       phoneNumber: item.phoneNumber,
                                       url: item.url,
                                       placemark: Placemark(coordinate: coordinate,
                                                            countryCode: placemark.countryCode,
                                                            administrativeArea: placemark.administrativeArea,
                                                            locality: placemark.locality,
                                                            thoroughfare: placemark.thoroughfare,
                                                            subThoroughfare: placemark.subThoroughfare)))
    }
}
