//
//  NavBarView.swift
//  eDocsNavPOC
//
//  Created by Sigurd Paul Mayer on 10/29/20.
//  Copyright © 2020 Sigurd Paul Mayer. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NavBarView : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnRefresh: UIButton!
    
    var navController : NavController!
    
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
