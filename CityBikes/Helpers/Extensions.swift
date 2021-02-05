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

extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"

    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}

extension String{
    var trimmed: String {
       return trimmingCharacters(in: .whitespacesAndNewlines)
   }
}


