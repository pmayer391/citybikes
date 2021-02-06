//
//  CityBikeResponse.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import Foundation
import MapKit

class CityBikeResponse : Codable {
    let networks : [Networks]?

    enum CodingKeys: String, CodingKey {
        case networks = "networks"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        networks = try values.decodeIfPresent([Networks].self, forKey: .networks)
    }
}

class Networks : Codable {
    let href : String?
    let id : String?
    let location : Location?
    let name : String?
    
    //UI Local Properties
    var isCellExpanded = false
    var annotation: MKAnnotation?
    var coords: CLLocationCoordinate2D?

    enum CodingKeys: String, CodingKey {
        case href = "href"
        case id = "id"
        case location = "location"
        case name = "name"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        href = try values.decodeIfPresent(String.self, forKey: .href)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        location = try values.decodeIfPresent(Location.self, forKey: .location)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}

class Location : Codable {
    let city : String?
    let country : String?
    let latitude : Double?
    let longitude : Double?

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

