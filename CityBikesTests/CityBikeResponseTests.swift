//
//  CityBikeResponseTests.swift
//  CityBikesTests
//
//  Created by Sigurd Paul Mayer on 2/7/21.
//

import XCTest
import MapKit

@testable import CityBikes
class CityBikeResponseTests: XCTestCase {
    
    var model: CityBikeResponse!
    
    override func setUp() {
        super.setUp()
        model = CityBikeResponse()
    }
    
    override func tearDown() {
        model = nil
        super.tearDown()
    }
    
    func test_valid_coords(){
        let coords = CLLocationCoordinate2D(latitude: 37.37778, longitude: -3.7907)
        XCTAssertTrue(model.checkForValidCoords(coords))
    }
    
    func test_valid_coords_zero(){
        let coords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        XCTAssertTrue(model.checkForValidCoords(coords))
    }
    
    func test_invalid_coords_length(){
        let coords = CLLocationCoordinate2D(latitude: 192810.4930, longitude: -2929990.0394)
        XCTAssertFalse(model.checkForValidCoords(coords))
    }
    
    func test_valid_network_list_by_id(){
        var networks = [Networks]()
        let firstNetwork = Networks()
        firstNetwork.id = "firstNetwork1"
        firstNetwork.name = "First Network"
        firstNetwork.href = "Href String"
        let firstLocation = Location()
        firstLocation.latitude = 37.37778
        firstLocation.longitude = -3.7907
        firstLocation.city = "Jaen"
        firstLocation.country = "ES"
        
        let secondNetwork = Networks()
        secondNetwork.id = "secondNetwork2"
        secondNetwork.name = "Second Network"
        secondNetwork.href = "Href String"
        let secondLocation = Location()
        secondLocation.latitude = 40.37778
        secondLocation.longitude = -37.7907
        secondLocation.city = "Eden"
        secondLocation.country = "Sitycleta"
        networks.append(firstNetwork)
        networks.append(secondNetwork)
        XCTAssert(model.validNetworkListById(networks))
    }
    
    func test_invalid_network_list_by_id(){
        var networks = [Networks]()
        let firstNetwork = Networks()
        firstNetwork.id = "firstNetwork1"
        firstNetwork.name = "First Network"
        firstNetwork.href = "Href String"
        let firstLocation = Location()
        firstLocation.latitude = 37.37778
        firstLocation.longitude = -3.7907
        firstLocation.city = "Jaen"
        firstLocation.country = "ES"
        
        let secondNetwork = Networks()
        secondNetwork.id = "firstNetwork1"
        secondNetwork.name = "Second Network"
        secondNetwork.href = "Href String"
        let secondLocation = Location()
        secondLocation.latitude = 40.37778
        secondLocation.longitude = -37.7907
        secondLocation.city = "Eden"
        secondLocation.country = "Sitycleta"
        networks.append(firstNetwork)
        networks.append(secondNetwork)
        XCTAssertFalse(model.validNetworkListById(networks))
    }
    
    func test_valid_network_list_by_location(){
        var networks = [Networks]()
        let firstNetwork = Networks()
        firstNetwork.id = "firstNetwork1"
        firstNetwork.name = "First Network"
        firstNetwork.href = "Href String"
        let firstLocation = Location()
        firstLocation.latitude = 37.37778
        firstLocation.longitude = -3.7907
        firstLocation.city = "Jaen"
        firstLocation.country = "ES"
        
        let secondNetwork = Networks()
        secondNetwork.id = "secondNetwork2"
        secondNetwork.name = "Second Network"
        secondNetwork.href = "Href String"
        let secondLocation = Location()
        secondLocation.latitude = 40.37778
        secondLocation.longitude = -37.7907
        secondLocation.city = "Eden"
        secondLocation.country = "Sitycleta"
        networks.append(firstNetwork)
        networks.append(secondNetwork)
        XCTAssertTrue(model.validNetworkListById(networks))
    }
    
    func test_invalid_network_list_by_location(){
        var networks = [Networks]()
        let firstNetwork = Networks()
        firstNetwork.id = "firstNetwork1"
        firstNetwork.name = "First Network"
        firstNetwork.href = "Href String"
        let firstLocation = Location()
        firstLocation.latitude = 37.37778
        firstLocation.longitude = -3.7907
        firstLocation.city = "Jaen"
        firstLocation.country = "ES"
        
        let secondNetwork = Networks()
        secondNetwork.id = "firstNetwork1"
        secondNetwork.name = "Second Network"
        secondNetwork.href = "Href String"
        let secondLocation = Location()
        secondLocation.latitude = 37.37778
        secondLocation.longitude = -3.7907
        secondLocation.city = "Eden"
        secondLocation.country = "Sitycleta"
        networks.append(firstNetwork)
        networks.append(secondNetwork)
        XCTAssertFalse(model.validNetworkListById(networks))
    }
    
    func test_not_empty_id(){
        let network = Networks()
        network.id = "testIdProp32"
        XCTAssertNotNil(network.id)
    }
    
    func test_empty_id(){
        let network = Networks()
        network.id = nil
        XCTAssertNil(network.id)
    }

}
