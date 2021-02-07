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

    //MARK: - Outlets
    @IBOutlet weak var navBar: NavBarView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var leftBikeWheel: UIImageView!
    @IBOutlet weak var rightBikeWheel: UIImageView!
    @IBOutlet weak var cityBikeTableView: UITableView!
    
    //MARK: - Properties
    var locationManager: CLLocationManager!
    var currentLocationStr = ""
    var networkList: [Networks] = []
    var selectedNetwork = ""
    let cityImg = UIImage(named: "cityIcon")
    var updateListFromMap = true
    var deselectListFromMap = true
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = true
        navBar.btnRefresh.addTarget(self, action: #selector(didTapOnRefresh(_:)), for: .touchUpInside)
        navBar.title = "City Bikes"
        mapView.delegate = self
        cityBikeTableView.delegate = self
        cityBikeTableView.dataSource = self
        cityBikeTableView.register(UINib(nibName: "CityBikesTVCell", bundle: .main), forCellReuseIdentifier: "CityBikesTVCell")
        cityBikeTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
        loadDataWithAnimation()
        
//        getCurrentLocation()
        //TO Show Blue Circle
//        mapView.showsUserLocation = true
    }
    
//    func getCurrentLocation() {
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//            mapView.isHidden = false
//        } else {
//            mapView.isHidden = true
//        }
//    }
    
    //MARK: - Refresh Functions
    @objc func didTapOnRefresh(_ sender: Any){
        loadDataWithAnimation()
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
    
    //MARK: - API Functions
    func callCityBikeAPI(){
        NetworkController.shared.getCityBikes { (data, errorString) in
            if let error = errorString{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation(error)
                }
            } else {
                self.networkList = data?.networks ?? []
                if !(self.networkList.isEmpty){
                    CoreDataController.shared.saveNetworksOnBackground(self.networkList)
                }
                
                
//                CoreDataController.shared.fetchEntity(entityName: "CDNetworks") { (cdNetworks) in

//                }
                
                
                DispatchQueue.main.async {
                    //TODO: Store In Core Data
                    self.stopLoadingAnimation()
                    self.dropCityBikePins()
                    self.cityBikeTableView.reloadData()
                    if self.cityBikeTableView.numberOfRows(inSection: 0) != 0 {
                        self.cityBikeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                }
            }
        }
    }
    
    //MARK: - Configure Map Pins
    func dropCityBikePins() {
        mapView.removeAnnotations(mapView.annotations)
        for network in networkList {
            if let lat = network.location?.latitude, let long = network.location?.longitude{
                let annotation = MKPointAnnotation()
                let coords = CLLocationCoordinate2D(latitude: lat, longitude: long)
                annotation.coordinate = coords
                annotation.title = network.name
                network.annotation = annotation
                network.coords = coords
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    //MARK: - Did Select City Functions
    func processSelectedValue(selectedIndexPath: IndexPath, updateMap: Bool = true){
        var refreshIndexes: [IndexPath] = []
        refreshIndexes.append(selectedIndexPath)
        let currentNetworkObj = networkList[selectedIndexPath.row]
        updateListFromMap = true
        deselectListFromMap = true
        //Previous Selected Indexes
        if !(selectedNetwork.isEmpty),
           let previousSelectedNetworkItem = networkList.filter({$0.id?.lowercased().trimmed == selectedNetwork.trimmed.lowercased()}).first, previousSelectedNetworkItem.id != currentNetworkObj.id ?? "", let index = networkList.firstIndex(where: {$0.id == selectedNetwork}){
            let previousIndexPath = IndexPath(row: index, section: 0)
            previousSelectedNetworkItem.isCellExpanded = false
            refreshIndexes.append(previousIndexPath)
        }
        
        //Current Selected Indexes
        if currentNetworkObj.isCellExpanded {
            currentNetworkObj.isCellExpanded = false
            selectedNetwork = ""
            mapView.selectedAnnotations = []
        } else {
            currentNetworkObj.isCellExpanded = true
            selectedNetwork = currentNetworkObj.id ?? ""
            if updateMap, let annotation = currentNetworkObj.annotation{
                updateListFromMap = false
                deselectListFromMap = false
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
        cityBikeTableView.reloadRows(at: refreshIndexes, with: .automatic)
        if !updateMap{
            scrollToExpandedCell(selectedIndexPath)
        }
    }
    
    func scrollToExpandedCell(_ indexPath : IndexPath) {
        self.cityBikeTableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
    
}

//MARK: - Map Kit Delegate
extension MainVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationView = view as? MKMarkerAnnotationView {
            annotationView.markerTintColor = .YellowLime()
            let selectedCoords = view.annotation?.coordinate
            if let coordinates = selectedCoords{
                let region = MKCoordinateRegion(center: coordinates, span: mapView.region.span)
                mapView.setRegion(region, animated: true)
            }
            //Compare selected Pin coords and retrieve the selected NetworkObj/IndexPath
            if updateListFromMap, let currentNetwork = networkList.filter({($0.coords?.latitude == selectedCoords?.latitude) && ($0.coords?.longitude == selectedCoords?.longitude)}).first, let index = networkList.firstIndex(where: {$0.id?.lowercased().trimmed == currentNetwork.id?.lowercased().trimmed}) {
                let selectedIndex = IndexPath(row: index, section: 0)
                processSelectedValue(selectedIndexPath: selectedIndex, updateMap: false)
            } else{
                updateListFromMap = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotationView = view as? MKMarkerAnnotationView {
            annotationView.markerTintColor = .DarkBlue()
            
            //Compare selected Pin coords and retrieve the selected NetworkObj/IndexPath
            if deselectListFromMap, !(selectedNetwork.isEmpty), let currentNetwork = networkList.filter({$0.id?.lowercased().trimmed == self.selectedNetwork.lowercased().trimmed}).first, let currentIndex = networkList.firstIndex(where: {$0.id?.lowercased().trimmed == currentNetwork.id?.lowercased().trimmed}) {
                let selectedIndex = IndexPath(row: currentIndex, section: 0)
                self.selectedNetwork = ""
                currentNetwork.isCellExpanded = false
                cityBikeTableView.reloadRows(at: [selectedIndex], with: .automatic)
            } else{
                deselectListFromMap = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cityPinAnnotation")
        annotationView.markerTintColor = .DarkBlue()
        annotationView.glyphImage = cityImg
        return annotationView
    }
    
}

//MARK: - Core Location Delegate
extension MainVC: CLLocationManagerDelegate{
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let mUserLocation:CLLocation = locations[0] as CLLocation
//
//    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if (status == CLAuthorizationStatus.denied) {
//            mapView.isHidden = true
//        } else {
//            mapView.isHidden = false
//        }
//    }
    
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
            return 100
        }
        return 50
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        processSelectedValue(selectedIndexPath: indexPath)
    }

}
