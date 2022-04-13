//
//  Data+Ext.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

extension Data {
    var dictionary: [String: Any] {
      guard let dictionary = try? JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any] else {
        return [:]
      }
      return dictionary
    }
}

