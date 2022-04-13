//
//  FSQPlace.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

struct AnyCodable: Codable {
}

struct FSQCategoryIcon: Codable {
    private(set) var prefix: String
    private(set) var suffix: String
}

struct FSQCategory: Codable {
    private(set) var id: Int
    private(set) var name: String
    private(set) var icon: FSQCategoryIcon
    
    var iconUrl: String {
        return "\(self.icon.prefix)\(64)\(self.icon.suffix)"
    }
}

struct FSQGeocodesCoordinates: Codable {
    private(set) var latitude: Double
    private(set) var longitude: Double
}

struct FSQGeocodes: Codable {
    private(set) var main: FSQGeocodesCoordinates
}

struct FSQLocation: Codable {
    private(set) var country: String
    private(set) var crossStreet: String
    private(set) var formattedAddress: String
    private(set) var postcode: String
    private(set) var locality: String
}

struct FSQRelatedPlace: Codable {}

struct FSQPlace: Codable {
    private(set) var fsqId: String
    private(set) var categories: [FSQCategory]
    private(set) var chains: [AnyCodable]
    private(set) var distance: Int
    private(set) var geocodes: FSQGeocodes
    private(set) var name: String
    private(set) var relatedPlaces: FSQRelatedPlace
    private(set) var timezone: String
}
