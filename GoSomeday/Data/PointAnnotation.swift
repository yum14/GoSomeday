//
//  PointAnnotation.swift
//  GoSomeday
//
//  Created by yum on 2021/04/21.
//

import Foundation
import MapKit

class PointAnnotation: MKPointAnnotation, Identifiable {
    var id: String
    
    init(id: String, title: String? = nil, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.id = id
        super.init()
        super.title = title
        super.subtitle = subtitle
        super.coordinate = coordinate
    }
}
