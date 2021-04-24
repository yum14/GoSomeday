//
//  MapItem.swift
//  GoSomeday
//
//  Created by yum on 2021/04/15.
//

import Foundation
import CoreLocation
import RealmSwift

class MapItem: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var url: String?
    @objc dynamic var placemark: Placemark?
    
    override init() {}
    
    convenience init(id: String = UUID().uuidString, name: String? = nil, phoneNumber: String? = nil, url: String? = nil, placemark: Placemark? = nil) {
        self.init()
        
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.url = url
        self.placemark = placemark
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Placemark: Object {
    @objc dynamic var coordinate: LocationCoordinate?
    @objc dynamic var countryCode: String?
    @objc dynamic var administrativeArea: String?
    @objc dynamic var locality: String?
    @objc dynamic var thoroughfare: String?
    @objc dynamic var subThoroughfare: String?

    override init() {}
    
    convenience init(coordinate: LocationCoordinate? = nil, countryCode: String? = nil, administrativeArea: String? = nil, locality: String? = nil, thoroughfare: String? = nil, subThoroughfare: String? = nil) {
        self.init()
        
        self.coordinate = coordinate
        self.countryCode = countryCode
        self.administrativeArea = administrativeArea
        self.locality = locality
        self.thoroughfare = thoroughfare
        self.subThoroughfare = subThoroughfare
    }
}

extension Placemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}

class LocationCoordinate: Object {
    @objc dynamic var latitude: Double
    @objc dynamic var longitude: Double
    
    override init() {
        self.latitude = 0
        self.longitude = 0
    }
    
    convenience init(latitude: Double, longitude: Double) {
        self.init()
        
        self.latitude = latitude
        self.longitude = longitude
    }
}
