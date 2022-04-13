//
//  ViewPresenter.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation
import CoreLocation
import CoreGraphics

protocol MapPresenterView: BasePresenterView {
    func addAnnotation(_ place: FSQPlace)
    func fetchPlacesOnViewportChange()
    func resetCamera(_ coordinate: CLLocationCoordinate2D)
}

class MapPresenter: BasePresenter<MapPresenterView> {
    
    private var lastCenter: CLLocationCoordinate2D!
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.view?.resetCamera(self.lastUserCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        self.startLocationUpdates()
        self.view?.fetchPlacesOnViewportChange()
    }
    
    var lastUserCoordinate: CLLocationCoordinate2D? {
        
        guard let lat = LocationManager.sharedInstance.lastCoordinates?.latitude,
            let lon = LocationManager.sharedInstance.lastCoordinates?.longitude else {
                return nil
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private func startLocationUpdates() {
        LocationManager.sharedInstance.delegate = self
        if !LocationManager.sharedInstance.isLocationServiceEnabled() {
            LocationManager.sharedInstance.requestAuthorization()
        }
        
        LocationManager.sharedInstance.startUpdating()
    }
    
    func cameraChanged(centerCoord: CLLocationCoordinate2D, zoom: CGFloat) {
        Api.fsq.fetchNearby(lat: centerCoord.latitude, lon: centerCoord.longitude) {[weak self] response in
            guard let result = response.result else { return }
            result.forEach { place in
                self?.view?.addAnnotation(place)
            }
        }
    }
}

extension MapPresenter: LocationManagerDelegate {
    func didUpdateTo(_ coordinate: CLLocationCoordinate2D) {
        self.view?.resetCamera(coordinate)
        cameraChanged(centerCoord: coordinate, zoom: 15)
    }
}
