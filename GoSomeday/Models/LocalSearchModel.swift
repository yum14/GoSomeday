//
//  LocalSearchModel.swift
//  GoSomeday
//
//  Created by yum on 2021/04/13.
//

import Foundation
import MapKit

class LocalSearchModel: ObservableObject {
    enum Result<T> {
        case success(T)
        case failure(Error)
    }
    
    @Published var response: Result<[MKMapItem]>?
    
    func search(query: String, region: MKCoordinateRegion? = nil, completion: @escaping ((Result<[MKMapItem]>) -> Void) = { _ in }) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        if let region = region {
            request.region = region
        }
        
        MKLocalSearch(request: request).start { (response, error) in
            if let error = error {
                self.response = .failure(error)
                completion(.failure(error))
                return
            }
            
            self.response = .success(response?.mapItems ?? [])
            completion(.success(response?.mapItems ?? []))
        }
    }
    
}
