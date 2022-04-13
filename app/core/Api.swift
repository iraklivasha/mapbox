//
//  Api.swift
//  app
//
//  Created by Irakli Vashakidze on 12.04.22.
//

import Foundation

class Api {

    private static let instance = Api()

    private var http: HttpAPI!
    private var fsq: FSQ!
    
    private init() {}

    class func setup() {
        instance.http = HttpAPIImpl()
        instance.fsq = FSQImpl(http: instance.http)
    }

    class var http: HttpAPI {
        return self.instance.http
    }
    
    class var fsq: FSQ {
        return self.instance.fsq
    }
}
