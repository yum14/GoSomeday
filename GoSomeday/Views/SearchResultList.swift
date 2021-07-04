//
//  SearchResultList.swift
//  GoSomeday
//
//  Created by yum on 2021/04/16.
//

import SwiftUI
import MapKit

struct SearchResultList: View {
    var items: [MapItem] = []
    var onTap: (MapItem) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 0) {            
            List {
                ForEach(self.items.indices, id: \.self) { index in
                    VStack {
                        HStack {
                            Text(self.items[index].name!)
                                .lineLimit(1)
                            Spacer()
                        }
                        HStack {
                            Text(self.items[index].placemark?.address ?? "")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        self.onTap(self.items[index])
                    }
                    .padding(.vertical, 8)
                    .id(index)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct SearchResultList_Previews: PreviewProvider {
    static var previews: some View {
        let items = [
            MapItem(id: "a", name: "name1", placemark: Placemark(administrativeArea: "area1")),
            MapItem(id: "b", name: "name2", placemark: Placemark(administrativeArea: "area2"))
        ]
        
        SearchResultList(items: items)
    }
}
