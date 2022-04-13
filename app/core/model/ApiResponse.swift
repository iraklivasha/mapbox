//
//  ApiResponse.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

struct ApiResponse<T: Codable> {
    private(set) var result: T?
    private(set) var error: Error?
}
