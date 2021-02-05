//
//  MainVC.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/4/21.
//

import UIKit
import MapKit
import CoreLocation

class MainVC: UIViewController {

    @IBOutlet weak var navBar: NavBarView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var leftBikeWheel: UIImageView!
    @IBOutlet weak var rightBikeWheel: UIImageView!
    @IBOutlet weak var cityBikeTableView: UITableView!
    
    var locationManager: CLLocationManager!
    var currentLocationStr = ""
    var networks: [Networks] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = true
        navBar.btnRefresh.addTarget(self, action: #selector(didTapOnRefresh(_:)), for: .touchUpInside)
        navBar.title = "City Bikes"
        loadDataWithAnimation()
        getCurrentLocation()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            mapView.isHidden = false
        } else {
            mapView.isHidden = true
        }
    }
    
    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                        }
                    }
                }
            }
        }
        return currentLocationStr
    }
    
    func callCityBikeAPI(){
        NetworkController.shared.getCityBikes { (data, errorString) in
            if let error = errorString{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation(error)
                }
            } else {
                self.networks = data?.networks ?? []
                print("NetWorks \(self.networks)")
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    //Store in Core Data and Reload Table View
                }
            }
        }
    }
    
    func loadDataWithAnimation(){
        leftBikeWheel.rotate()
        rightBikeWheel.rotate()
        UIView.animate(withDuration: 1.1, delay: 0.3, options: [.curveEaseInOut]) {
            self.loadingView.isHidden = false
        } completion: { (complete) in
            self.callCityBikeAPI()
        }
    }
    
    func stopLoadingAnimation(_ error: String = ""){
        self.leftBikeWheel.stopRotating()
        self.rightBikeWheel.stopRotating()
        UIView.animate(withDuration: 1.1, delay: 0.4, options: [.curveEaseInOut]) {
            self.loadingView.isHidden = true
        } completion: { (complete) in
            if error != ""{
                self.showAlert(error)
            }
        }
    }
    
    @objc func didTapOnRefresh(_ sender: Any){
        loadDataWithAnimation()
    }
}

extension MainVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Handle when pin selected")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Handle when pin is deseleced")
    }
    
}

extension MainVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
//
//        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
//        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0))
//
//        mapView.setRegion(mRegion, animated: true)
        
        // Get user's Current Location and Drop a pin
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
            mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
            mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
            mapView.addAnnotation(mkAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            mapView.isHidden = true
        } else {
            mapView.isHidden = false
        }
    }
    
}
