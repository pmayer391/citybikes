//
//  NavBarView.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/4/21.
//

import Foundation
import UIKit

@IBDesignable
class NavBarView : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var navController: NavController!
    var title: String = ""{
        didSet{
            lblTitle.text = title
        }
    }
    
    //Mark: Class Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let bundle = Bundle(for: NavBarView.self)
        let nib = UINib(nibName: "NaBarView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navController.popViewController(animated: true)
    }
    
    @IBAction func refreshBtnPressed(_ sender: UIButton) {
        
    }
}
