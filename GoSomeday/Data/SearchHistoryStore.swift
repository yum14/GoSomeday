//
//  SearchHistoryStore.swift
//  GoSomeday
//
//  Created by yum on 2021/04/25.
//

import Foundation
import RealmSwift

final class SearchHistoryStore: ObservableObject {
    static let shared = SearchHistoryStore()
    @Published var mapItems: List<MapItem>
    private var notificationTokens: [NotificationToken] = []
    private var realmObject: SearchHistory
    
    private init() {
        let realm = RealmHelper.createRealm()
        var mapItems = realm.object(ofType: SearchHistory.self, forPrimaryKey: 0)
        if mapItems == nil {
            mapItems = try! realm.write{ realm.create(SearchHistory.self, value: SearchHistory())}
        }
        self.realmObject = mapItems!
        
        // freezeによってイミュータブルにしないとエラーになる
        self.mapItems = self.realmObject.mapItems.freeze()
        
        notificationTokens.append(self.realmObject.mapItems.observe { change in
            switch change {
            case let .initial(results):
                self.mapItems = results.freeze()
            case let .update(results, _, _, _):
                self.mapItems = results.freeze()
            case let .error(error):
                print(error.localizedDescription)
            }
        })
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
    
    func add(_ mapItem: MapItem) -> Void {
        let realm = RealmHelper.createRealm()
        try! realm.write {
            let newMapItem = mapItem
            
            if let maxOrder = self.realmObject.mapItems.max(by: { $0.order < $1.order })?.order {
                newMapItem.order = maxOrder + 1
            } else {
                newMapItem.order = 0
            }
            
            self.realmObject.mapItems.append(mapItem)
        }
    }
    
    func delete(id: String) {
        
        guard let index = realmObject.mapItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        let realm = RealmHelper.createRealm()
        try! realm.write {
            self.realmObject.mapItems.remove(at: index)
            
        }
    }
    
}
