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
    var networkList: [Networks] = []
    var selectedNetwork = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = true
        navBar.btnRefresh.addTarget(self, action: #selector(didTapOnRefresh(_:)), for: .touchUpInside)
        navBar.title = "City Bikes"
        cityBikeTableView.delegate = self
        cityBikeTableView.dataSource = self
        cityBikeTableView.register(UINib(nibName: "CityBikesTVCell", bundle: .main), forCellReuseIdentifier: "CityBikesTVCell")
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
                self.networkList = data?.networks ?? []
                debugPrint("NetWorks \(self.networkList)")
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    //Store in Core Data and Reload Table View
                    self.cityBikeTableView.reloadData()
                }
            }
        }
    }
    
    func loadDataWithAnimation(){
        navBar.btnRefresh.isEnabled = false
        leftBikeWheel.rotate()
        rightBikeWheel.rotate()
        UIView.animate(withDuration: 0.75, delay: 0.3, options: [.curveEaseInOut]) {
            self.loadingView.isHidden = false
        } completion: { (complete) in
            self.callCityBikeAPI()
        }
    }
    
    func stopLoadingAnimation(_ error: String = ""){
        self.leftBikeWheel.stopRotating()
        self.rightBikeWheel.stopRotating()
        UIView.animate(withDuration: 0.75, delay: 0.1, options: [.curveEaseInOut]) {
            self.loadingView.isHidden = true
        } completion: { (complete) in
            if error != ""{
                self.showAlert(error)
            }
            self.navBar.btnRefresh.isEnabled = true
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

// MARK: - TableView Delegate and Data Methods
extension MainVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityBikesTVCell", for: indexPath) as! CityBikesTVCell
        cell.configureCell(networkList[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if networkList[indexPath.row].isCellExpanded{
            return 90
        }
        return 45
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Restrict the Current Route from being selected

        //If a Row is already showing Expanded...
//        if let selectedRouteIndexPath = self.selectedRouteIndexPath{
            //Minimize Row
//            if selectedRouteIndexPath == indexPath {
//                if expandedRowsDic[indexPath.row] ?? false{
//                    expandedRowsDic[indexPath.row] = false
//                    self.selectedRouteIndexPath = nil
//                    self.previousRouteIndexPath = nil
//                    tableView.reloadRows(at: [indexPath], with: .automatic)
//                    if tableView.visibleCells.count - 3 < indexPath.row {
//                        scrollToExpandedCell(tableView, indexPath)
//                    }
//                }
//            } else { //Expand New Row and Minimize Previous Selection
        let networkObj = networkList[indexPath.row]
        if networkObj.isCellExpanded {
//                expandedRowsDic.keys.forEach{expandedRowsDic[$0] = false}
//                expandedRowsDic[indexPath.row] = true
//                self.previousRouteIndexPath = self.selectedRouteIndexPath
//                self.selectedRouteIndexPath = indexPath
            networkObj.isCellExpanded = false
            selectedNetwork = ""
                var refreshPathsArr = [IndexPath]()
                refreshPathsArr.append(indexPath)
//                if let previousIndex = self.previousRouteIndexPath {
//                    refreshPathsArr.append(previousIndex)
//                }
                tableView.reloadRows(at: refreshPathsArr, with: .automatic)
                //Scroll an aditional 65 pixels for the expanded view if one of the last three visable cells were expanded
//                if tableView.visibleCells.count - 3 < indexPath.row {
//                    scrollToExpandedCell(tableView, indexPath)
//                }
//            }
        } else { //else if no Row is showing...Expand Row
//            expandedRowsDic[indexPath.row] = true
//            self.selectedRouteIndexPath = indexPath
            if !(selectedNetwork.isEmpty){
                networkList.filter({$0.id?.lowercased().trimmed == selectedNetwork.trimmed.lowercased()}).first?.isCellExpanded = false
            }
            selectedNetwork = networkObj.id ?? ""
            tableView.reloadRows(at: [indexPath], with: .automatic)
            //Scroll an aditional 65 pixels if one of the last three visable cells were expanded
            if tableView.visibleCells.count - 3 < indexPath.row {
                scrollToExpandedCell(tableView, indexPath)
            }
        }
    }

    func scrollToExpandedCell(_ tableView : UITableView, _ indexPath : IndexPath) {
        DispatchQueue.main.async {
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }

}
