//
//  fsq.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

protocol FSQ: AnyObject {
    func fetchNearby(lat: Double,
                     lon: Double,
                     completion:@escaping(ApiResponse<[FSQPlace]>) -> Void)
}

class FSQImpl: FSQ {
    
    private var http: HttpAPI!
    init(http: HttpAPI) {
        self.http = http
    }
    
    func fetchNearby(lat: Double,
                     lon: Double,
                     completion:@escaping(ApiResponse<[FSQPlace]>) -> Void) {
        
        let headers = [
          "Accept": "application/json",
          "Authorization": Consts.api.key.foursquare
        ]
        
        Api.http.send(for: Consts.api.url.fsq,
                         method: .get,
                         params: ["ll": "\(lat),\(lon)"], headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    let arr = try Decoder.defaultDecoder.decode([FSQPlace].self, from: data!)
                    completion(ApiResponse(result: arr, error: nil))
                } catch let e {
                    completion(ApiResponse(result: nil, error: e))
                }
                
                break
            case .failure(let error):
                completion(ApiResponse(result: nil, error: error))
                break
            }
        }
    }
}
