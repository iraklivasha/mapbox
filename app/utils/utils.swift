//
//  utils.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation
import CoreLocation
import CoreGraphics

func distanceDouble(between location1: CLLocation, location2: CLLocation) -> Double {
    let distance = location1.distance(from: location2) / 1000
    return distance
}

private func async(block:@escaping ()->Void, on queue: DispatchQueue = DispatchQueue.main) {
    queue.async(execute: block)
}

func main(block:@escaping ()->Void) {
    async(block: block)
}

func deg2rad(_ degree: CGFloat) -> CGFloat {
    return degree * CGFloat(Float.pi) / 180
}
