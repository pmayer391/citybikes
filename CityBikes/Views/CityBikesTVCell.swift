//
//  CityBikesTVCell.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import UIKit

class CityBikesTVCell: UITableViewCell {

    @IBOutlet weak var imgCity: CBImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var additionalInfoView: UIView!
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblLon: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgCity.image = imgCity.image?.withRenderingMode(.alwaysTemplate)
        self.contentView.layer.borderWidth = 0.5
    }
    
    func configureCell(_ networkObj: Networks){
        lblTitle.text = "\(networkObj.name ?? "") - \(networkObj.company?.strVal ?? "")"
        lblSubTitle.text = "\(networkObj.location?.city ?? "--"), \(networkObj.location?.country ?? "--")"
        lblLat.text = "LAT: \(networkObj.location?.latitude ?? 0.000)"
        lblLon.text = "LONG: \(networkObj.location?.longitude ?? 0.000)"
        
        if networkObj.isCellExpanded {
            additionalInfoView.isHidden = false
            imgCity.tintColor = .YellowLime()
            lblTitle.textColor = .YellowLime()
            lblSubTitle.textColor = .YellowLime()
            self.contentView.layer.borderColor = UIColor.YellowLime().cgColor
        } else{
            additionalInfoView.isHidden = true
            imgCity.tintColor = .white
            lblTitle.textColor = .white
            lblSubTitle.textColor = .white
            self.contentView.layer.borderColor = UIColor.DarkBlue().cgColor
        }
    }

    
}
