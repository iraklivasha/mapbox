//
//  Dictionary+Ext.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

extension Collection {
    var data: Data {
        let data = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return data ?? Data()
    }
}

