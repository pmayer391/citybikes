//
//  MainVC.swift
//  Control4WeatherApp
//
//  Created by APRIL MAYER on 2/4/21.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "City Bikes"
//        navigationController?.navigationBar.barTintColor = .DarkBlue()
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barStyle = .black
//        let navItem = UINavigationItem(title: "Refresh")
//        navigationController?.navigationBar.items = [navItem]
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle{
//        .lightContent
//    }

    @IBAction func didTapOnGetWeatherData(_ sender: Any) {
//        NetworkService.shared.getWeatherData { (data, errorString) in
//            if let error = errorString{
//                self.showAlert(error)
//            }
//            if let data = data{
//                print(data)
//            }
//        }
    }
    
    @objc func didTapOnRefresh(_ sender: Any){
        
    }
}
