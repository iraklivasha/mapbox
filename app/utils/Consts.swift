//
//  Consts.swift
//  app
//
//  Created by Irakli Vashakidze on 12.04.22.
//

import Foundation

struct Consts {
    struct api {
        struct key {
            static let mapBox = "pk.eyJ1IjoiaXJha2xpdmFzaGEiLCJhIjoiY2wxd2lqdXdnMDk3YjNpbzlxcGszcmt3ZyJ9.UkYqYuwTHn2_z9oaHOaLMg";
            static let foursquare = "fsq3adg8Yxd4Ih8zv/KqXkl5YcqbErJ46ZpL+4YkH3yAIqs="
        }
        
        struct url {
            static let fsq = URL(string: "https://api.foursquare.com/v3/places/nearby")!
        }
    }
    
    struct notifications {
        static let didChangeUser = Notification.Name("didChangeUser")
        static let connectionChanged = Notification.Name("connectionChanged")
        static let didChangeLocationPermissions = Notification.Name("didChangeLocationPermissions")
    }
    
}
