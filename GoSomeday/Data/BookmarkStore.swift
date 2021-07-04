//
//  BookmarkStore.swift
//  GoSomeday
//
//  Created by yum on 2021/04/25.
//

import Foundation
import RealmSwift

final class BookmarkStore: ObservableObject {
    static let shared = BookmarkStore()
    @Published var annotations: List<PointAnnotation>
    private var notificationTokens: [NotificationToken] = []
    private var realmObject: Bookmark
    
    private init() {
        let realm = RealmHelper.createRealm()
        var mapItems = realm.object(ofType: Bookmark.self, forPrimaryKey: 0)
        if mapItems == nil {
            mapItems = try! realm.write{ realm.create(Bookmark.self, value: Bookmark())}
        }
        self.realmObject = mapItems!
        
        // freezeによってイミュータブルにしないとエラーになる
        self.annotations = self.realmObject.annotations.freeze()
        
        notificationTokens.append(self.realmObject.annotations.observe { change in
            switch change {
            case let .initial(results):
                self.annotations = results.freeze()
            case let .update(results, _, _, _):
                self.annotations = results.freeze()
            case let .error(error):
                print(error.localizedDescription)
            }
        })
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
    
    func add(_ annotation: PointAnnotation) -> Void {
        let realm = RealmHelper.createRealm()
        try! realm.write {
            self.realmObject.annotations.append(annotation)
        }
    }
    
    func delete(atOffsets: IndexSet) {
        let realm = RealmHelper.createRealm()
        try! realm.write {
            self.realmObject.annotations.remove(atOffsets: atOffsets)
        }
    }
    
}
