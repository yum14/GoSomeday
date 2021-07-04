//
//  SearchHistory.swift
//  GoSomeday
//
//  Created by yum on 2021/04/15.
//

import Foundation
import RealmSwift

class SearchHistory: Object, Identifiable {
    @objc dynamic var id: Int = 0
    let mapItems = List<MapItem>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
