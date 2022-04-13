//
//  BaseView.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import UIKit

class BaseView : UIView {
    
    init() {
        super.init(frame: CGRect.zero)
        self._configure()
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._configure()
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._configure()
        self.configure()
    }
    
    fileprivate func _configure() {
        
    }
    
    func configure() {
        
    }
    
}

class CircleView: BaseView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
    }
}
