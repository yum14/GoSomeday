//
//  Bookmark.swift
//  GoSomeday
//
//  Created by yum on 2021/04/25.
//

import Foundation
import RealmSwift

class Bookmark: Object, Identifiable {
    @objc dynamic var id: Int = 0
    let annotations = List<PointAnnotation>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
