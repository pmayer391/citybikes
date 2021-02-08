//
//  CBImageView.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import Foundation
import UIKit

@IBDesignable
class CBImageView: UIImageView {
    
    @IBInspectable var imageColor: UIColor = UIColor.clear {
        didSet{
            self.setImageProperties()
        }
    }

    func setImageProperties(){
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = imageColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setImageProperties()
    }
}
