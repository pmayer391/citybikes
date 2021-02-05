//
//  CityBikesTVCell.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import UIKit

class CityBikesTVCell: UITableViewCell {

    @IBOutlet weak var imgCity: CGImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var additionalInfoView: UIView!
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblLon: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgCity.image = imgCity.image?.withRenderingMode(.alwaysTemplate)
//        self.contentView.layer.borderWidth = 1
    }
    
    func configureCell(_ networkObj: Networks){
        lblTitle.text = networkObj.name ?? "--"
        lblSubTitle.text = "\(networkObj.location?.city ?? "--"), \(networkObj.location?.country ?? "--")"
        lblLat.text = "\(networkObj.location?.latitude ?? 0.000)"
        lblLon.text = "\(networkObj.location?.longitude ?? 0.000)"
        
        if networkObj.isCellExpanded {
            additionalInfoView.isHidden = false
            imgCity.tintColor = .YellowLime()
            lblTitle.tintColor = .YellowLime()
            lblSubTitle.tintColor = .YellowLime()
            lblLon.tintColor = .YellowLime()
            self.contentView.layer.borderColor = UIColor.YellowLime().cgColor
        } else{
            additionalInfoView.isHidden = true
            imgCity.tintColor = .white
            lblTitle.tintColor = .white
            lblSubTitle.tintColor = .white
            lblLon.tintColor = .white
            self.contentView.layer.borderColor = UIColor.white.cgColor
        }
    }

    
}
