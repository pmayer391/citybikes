//
//  CityBikeResponse.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import Foundation
import MapKit

class CityBikeResponse : NSObject, Codable {
    var networks : [Networks]?
    
    override init() {
    }

    enum CodingKeys: String, CodingKey {
        case networks = "networks"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        networks = try values.decodeIfPresent([Networks].self, forKey: .networks)
    }
}

class Networks : NSObject, Codable {
//    let company : [String]?
    var href : String?
    var id : String?
    var location : Location?
    var name : String?

    //UI Local Properties
    var isCellExpanded = false
    var annotation: MKAnnotation?
    var coords: CLLocationCoordinate2D?
    
    override init() {
    }

    enum CodingKeys: String, CodingKey {
//        case company = "company"
        case href = "href"
        case id = "id"
        case location = "location"
        case name = "name"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
//        company = try values.decodeIfPresent([String].self, forKey: .company)
        href = try values.decodeIfPresent(String.self, forKey: .href)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        location = try values.decodeIfPresent(Location.self, forKey: .location)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}

class Location : NSObject, Codable {
    var city : String?
    var country : String?
    var latitude : Double?
    var longitude : Double?
    
    override init() {
    }

    enum CodingKeys: String, CodingKey {
        case city = "city"
        case country = "country"
        case latitude = "latitude"
        case longitude = "longitude"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
    }
}

