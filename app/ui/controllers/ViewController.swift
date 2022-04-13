//
//  ViewController.swift
//  app
//
//  Created by Irakli Vashakidze on 12.04.22.
//

import UIKit
import UIKit
import MapboxMaps
import ReSwift
import SnapKit

class ViewController: UIViewController {

    private let presenter = MapPresenter()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label;
    }()
    
    private lazy var btnUp: UIButton = {
        let label = UIButton()
        label.setTitle("Up", for: .normal)
        label.setTitleColor(.blue, for: .normal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addTarget(self, action: #selector(increase), for: .touchUpInside)
        return label;
    }()
    
    private lazy var btnDown: UIButton = {
        let label = UIButton()
        label.setTitle("Down", for: .normal)
        label.setTitleColor(.blue, for: .normal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addTarget(self, action: #selector(decrease), for: .touchUpInside)
        return label;
    }()
    
    private var markers = Set<MarkerView>()
    private var mapView: MapView!
     
    override public func viewDidLoad() {
        super.viewDidLoad()
        layout()
        presenter.attach(this: self)
    }
    
    private func layout() {
        let myResourceOptions = ResourceOptions(accessToken: Consts.api.key.mapBox)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.gestures.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
    }
    
    private func cleanupOutofboundsMarkers() {
        
        var markersToRemove = [MarkerView]()
        let bounds = self.mapView.mapboxMap.coordinateBounds(for: self.mapView.bounds)
        
        markers.forEach { marker in
            if !bounds.contains(forPoint: marker.coordinates, wrappedCoordinates: false) {
                markersToRemove.append(marker)
            }
        }
        
        markersToRemove.forEach { marker in
            mapView.viewAnnotations.remove(marker)
            markers.remove(marker)
        }
    }

    private func addButtons() {
        self.view.addSubview(counterLabel)
        self.view.addSubview(btnUp)
        self.view.addSubview(btnDown)
        
        counterLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        btnUp.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
            make.top.equalTo(48)
        }
        
        btnDown.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
            make.top.equalTo(92)
        }
    }
    
    @objc func increase() {
        mainStore.dispatch(CounterActionIncrease());
    }
    
    @objc func decrease() {
        mainStore.dispatch(CounterActionDecrease());
    }
}

extension ViewController: StoreSubscriber {
    func newState(state: AppState) {
        // when the state changes, the UI is updated to reflect the current state
        counterLabel.text = "\(mainStore.state.counter)"
    }
}

extension ViewController: MapPresenterView {
    
    func notifyError(message: String, okAction: (() -> Void)?) {}
    
    func reloadView() {}
    
    func willAppear() {
        
    }
    
    func willDisappear() {}
    
    func addAnnotation(_ place: FSQPlace) {
        let coord = CLLocationCoordinate2D(latitude: place.geocodes.main.latitude,
                                           longitude: place.geocodes.main.longitude)
        let options = ViewAnnotationOptions(
            geometry: Point(coord),
            width: 40,
            height: 40,
            allowOverlap: false,
            anchor: .center
        )
        let marker = MarkerView()
        marker.tapHandler = {[weak self] (place) in
            // TODO: details
            debugPrint("Marker: \(place)")
        }
        marker.place = place
        self.markers.insert(marker)
        try? mapView.viewAnnotations.add(marker, options: options)
    }
    
    func resetCamera(_ coordinate: CLLocationCoordinate2D) {
        let cameraOptions = CameraOptions(center: coordinate,
                                                  zoom: 15,
                                                  bearing: -17.6,
                                                  pitch: 45)
        
        mapView.mapboxMap.setCamera(to: cameraOptions)
    }
    
    func fetchPlacesOnViewportChange() {
        self.cleanupOutofboundsMarkers()
        self.presenter.cameraChanged(centerCoord: self.mapView.mapboxMap.cameraState.center,
                                     zoom: self.mapView.mapboxMap.cameraState.zoom)
    }
}


extension ViewController: GestureManagerDelegate {
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {}
    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {}
    
    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        fetchPlacesOnViewportChange()
    }
}
