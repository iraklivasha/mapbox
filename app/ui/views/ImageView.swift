//
//  ImageView.swift
//  app
//
//  Created by Irakli Vashakidze on 12.04.22.
//

import UIKit
import Nuke

class ImageView: UIImageView {
    
    func setImage(from url: String?, placeholder: UIImage? = UIImage(named: "red_pin")) {
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder"),
            transition: .fadeIn(duration: 0.33)
        )
        
        guard let url = url else {
            self.image = placeholder
            return
        }
        
        Nuke.loadImage(with: url, options: options, into: self) { result in
            switch result {
            case .failure(_):
                self.image = placeholder
                break
            default: break
            }
        }
    }
}

class CircleImageView: ImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
    }
}
