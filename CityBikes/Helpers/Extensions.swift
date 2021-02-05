//
//  Extensions.swift
//  KnowInkCodeTest
//
//  Created by APRIL MAYER on 2/4/21.
//

import Foundation
import UIKit

extension UIViewController{
    
    func showAlert(_ message: String?){
        let alertVC = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let alertContinue = UIAlertAction(title: "Continue", style: .default, handler: nil)
        alertVC.addAction(alertContinue)
        self.present(alertVC, animated: true, completion: nil)
    }
}
