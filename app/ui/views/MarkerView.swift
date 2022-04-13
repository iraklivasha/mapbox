//
//  MarkerView.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation
import CoreLocation
import UIKit

class MarkerView: CircleView {
    
    var place: FSQPlace! {
        didSet {
            self.setImage(url: place.categories.first?.iconUrl)
        }
    }
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: place.geocodes.main.latitude, longitude: place.geocodes.main.longitude)
    }
    
    var tapHandler: ((FSQPlace) -> Void)?
    
    let imageView = CircleImageView()
    private lazy var rotate: CABasicAnimation = {
        let trans = CABasicAnimation(keyPath: "transform.rotation");
        trans.duration = 0.6
        trans.fromValue = 0
        trans.toValue = deg2rad(360)
        trans.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        trans.isAdditive = true
        trans.fillMode = .forwards
        return trans
    }()
    
    override func configure() {
        super.configure()
        self.backgroundColor = .white
        imageView.backgroundColor = .red
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.9)
        }
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(placeClicked)))
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        imageView.layer.add(rotate, forKey: "rotation")
    }
    
    @objc private func placeClicked() {
        tapHandler?(place)
    }
    
    private func setImage(url: String?) {
        self.imageView.setImage(from: url)
    }
}
