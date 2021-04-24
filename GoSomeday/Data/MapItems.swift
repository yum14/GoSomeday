//
//  MapItems.swift
//  GoSomeday
//
//  Created by yum on 2021/04/15.
//

import Foundation
import RealmSwift

class MapItems: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    let items = List<MapItem>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
