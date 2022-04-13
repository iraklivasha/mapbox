//
//  decoder.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

class Decoder: JSONDecoder {
    
    static var defaultDecoder: Decoder {
        let decoder = Decoder()
        decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
        return decoder
    }
    
    private enum CodingKeys: String {
        case results
    }
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        
        let __value = data.dictionary[CodingKeys.results.rawValue]
        
        if let value = __value as? [Any] {
            return try super.decode(T.self, from: value.data)
        }
        
        if let value = __value as? [String: Any] {
            return try super.decode(T.self, from: value.data)
        }
        
        throw CIError(rawValue: CIError.invalidContent.code)
    }
}

