//
//  PointAnnotation.swift
//  GoSomeday
//
//  Created by yum on 2021/04/21.
//

import Foundation
import RealmSwift

class PointAnnotation: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String?
    @objc dynamic var subtitle: String?
    @objc dynamic var coordinate: LocationCoordinate?
    
    override init() {}
    
    convenience init(id: String? = nil, title: String? = nil, subtitle: String? = nil, coordinate: LocationCoordinate) {
        self.init()
        
        if let id = id {
            self.id = id
        }

        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
