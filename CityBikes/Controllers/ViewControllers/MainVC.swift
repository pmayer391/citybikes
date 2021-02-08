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
    var cdNetworkList: [Networks] = []
    var selectedNetwork = ""
    let cityImg = UIImage(named: "cityIcon")
    var updateListFromMap = true
    var deselectListFromMap = true
    var sortList: [SortOption] = [.Ascending, .Decending, .City, .NearestCity]
    var currentSortOption: SortOption = .Ascending
    var currentUserLocation: CLLocation?
    
    enum SortOption: String{
        case Ascending = "Ascending"
        case Decending = "Decending"
        case City = "City"
        case NearestCity = "Nearest Location"
    }
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = true
        navBar.btnRefresh.addTarget(self, action: #selector(didTapOnRefresh(_:)), for: .touchUpInside)
        navBar.btnSort.addTarget(self, action: #selector(didTapOnSort(_:)), for: .touchUpInside)
        navBar.title = "City Bikes"
        mapView.delegate = self
        cityBikeTableView.delegate = self
        cityBikeTableView.dataSource = self
        cityBikeTableView.register(UINib(nibName: "CityBikesTVCell", bundle: .main), forCellReuseIdentifier: "CityBikesTVCell")
        cityBikeTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
        loadDataWithAnimation()
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            if !(sortList.contains(.NearestCity)){
                sortList.append(.NearestCity)
            }
        } else {
            if sortList.contains(.NearestCity), let index = sortList.firstIndex(where: {$0 == .NearestCity}){
                sortList.remove(at: index)
            }
        }
    }
    
    //MARK: - Refresh Functions
    @objc func didTapOnRefresh(_ sender: UIButton){
        loadDataWithAnimation()
    }
    
    func loadDataWithAnimation(){
        navBar.btnRefresh.isEnabled = false
        navBar.btnSort.isEnabled = false
        leftBikeWheel.rotate()
        rightBikeWheel.rotate()
        self.navBar.imgRefresh.tintColor = .YellowLime()
        self.navBar.lblRefresh.textColor = .YellowLime()
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
            self.navBar.imgRefresh.tintColor = .white
            self.navBar.lblRefresh.textColor = .white
            self.navBar.btnRefresh.isEnabled = true
            self.navBar.btnSort.isEnabled = true
            if error != ""{
                self.showAlert(error)
            }
        }
    }
    
    //MARK: - Sort Functions
    @objc func didTapOnSort(_ sender: UIButton){
        if let topVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? UINavigationController{
            UIView.animate(withDuration: 0.1) {
                self.navBar.imgSort.tintColor = .YellowLime()
                self.navBar.lblSort.textColor = .YellowLime()
            }
            let sourceView = sender.convert(sender.bounds, to: topVC.view)
            let dropdown = DropDownView(sourceView: sourceView, customCellName: "", direction: .ArrowDown, maxWidth: 150, maxHeight: 39 * CGFloat(sortList.count), xOffset: nil, yOffset: nil, arrowOffset: nil, bgColor: .DarkBlue(), cornerRadias: 12, autoDismiss: true, addShadow: true, borderWidth: nil, borderColor: nil, addCellSeparator: nil)
            dropdown.delegate = self
            dropdown.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            dropdown.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            topVC.present(dropdown, animated: false, completion: nil)
        }
    }
    
    func setSortOption(){
        switch currentSortOption {
        case .Ascending:
            networkList = networkList.sorted { $0.name?.lowercased().trimmed ?? "" < $1.name?.lowercased().trimmed ?? "" }
        case .Decending:
            networkList = networkList.sorted { $0.name?.lowercased().trimmed ?? "" > $1.name?.lowercased().trimmed ?? "" }
        case .City:
            networkList = networkList.sorted { $0.location?.city?.lowercased().trimmed ?? "" < $1.location?.city?.lowercased().trimmed ?? ""}
        case .NearestCity:
            let coodsTo = CLLocation(latitude: currentUserLocation?.coordinate.latitude ?? 0.0, longitude: currentUserLocation?.coordinate.longitude ?? 0.0)
            for network in networkList{
                let coordsFrom = CLLocation(latitude: network.location?.latitude ?? 0.0, longitude: network.location?.longitude ?? 0.0)
                network.distanceFromDeviceLocation = coodsTo.distance(from: coordsFrom) // result is in meters
            }
            networkList = networkList.sorted { $0.distanceFromDeviceLocation ?? 0.0 < $1.distanceFromDeviceLocation ?? 0.0 }
        }
        DispatchQueue.main.async {
            self.cityBikeTableView.reloadData()
            if self.cityBikeTableView.numberOfRows(inSection: 0) != 0 {
                self.cityBikeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    //MARK: - GET API / CoreData
    func callCityBikeAPI(){
        NetworkController.shared.getCityBikes { (data, errorString) in
            if let error = errorString{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation(error)
                }
                //Load Core Data Networks on Backround
                self.loadCoreDataNetworks()
            } else {
                self.networkList = data?.networks ?? []
                //Store in Core Data On Background Thread
                if !(self.networkList.isEmpty){
                    CoreDataController.shared.refreshNetworksOnBackground(self.networkList)
                }
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    self.dropCityBikePins()
                    self.setSortOption()
                }
            }
        }
    }
    
    func loadCoreDataNetworks(){
        CoreDataController.shared.fetchNetworksOnBackground(mainThread: true) { (networksFromCD, nil) in
            if let networksFromCoreData = networksFromCD{
                self.cdNetworkList = networksFromCoreData
                if self.cdNetworkList.count > 0{
                    self.networkList = self.cdNetworkList
                    DispatchQueue.main.async {
                        self.dropCityBikePins()
                        self.setSortOption()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations[0] as CLLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            if sortList.contains(.NearestCity), let index = sortList.firstIndex(where: {$0 == .NearestCity}){
                sortList.remove(at: index)
            }
        } else {
            if !(sortList.contains(.NearestCity)){
                sortList.append(.NearestCity)
            }
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

//MARK: - Drop Down Delegate
extension MainVC : DrowDownDelegate{
    
    func tableViewPopup(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let sortItem = sortList[indexPath.row]
        if sortItem == currentSortOption{
            cell.textLabel?.textColor = .YellowLime()
        } else {
            cell.textLabel?.textColor = .white
        }
        cell.contentView.backgroundColor = .DarkBlue()
        cell.textLabel?.text = sortItem.rawValue.capitalized
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableViewPopup(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortList.count
    }
    
    func tableViewPopup(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSortOption = sortList[indexPath.row]
        setSortOption()
    }
    
    func tableViewPopup(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 39
    }
    
    func popupDismissed() {
        UIView.animate(withDuration: 0.1) {
            self.navBar.imgSort.tintColor = .white
            self.navBar.lblSort.textColor = .white
        }
    }
}
