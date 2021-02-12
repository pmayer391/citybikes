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
    
    func validNetworkListById(_ networkList: [Networks]) -> Bool{
        let groupedNetworksById = networkList.group(by: {$0.id})
        for (_, networks) in groupedNetworksById{
            if networks.count > 1{
                return false
            }
        }
        return true
    }
    
    func validNetworkListByLocation(_ networkList: [Networks]) -> Bool{
        let groupedLatitude = networkList.group(by: {$0.location?.latitude})
        let groupedLongitude = networkList.group(by: {$0.location?.longitude})
        if groupedLatitude.count == groupedLongitude.count && groupedLatitude.count == groupedLatitude.count{
            return true
        }
        return false
    }
    
    func checkForValidCoords(_ coords: CLLocationCoordinate2D) -> Bool{
        if (CLLocationCoordinate2DIsValid(coords)) {
          return true
        } else {
          return false
        }
    }
}

class Networks : NSObject, Codable {
    var company : CompanyObj?
    var href : String?
    var id : String?
    var location : Location?
    var name : String?

    //UI Local Properties
    var isCellExpanded = false
    var annotation: MKAnnotation?
    var coords: CLLocationCoordinate2D?
    var distanceFromDeviceLocation: CLLocationDistance?
    
    override init() {
    }

    enum CodingKeys: String, CodingKey {
        case company = "company"
        case href = "href"
        case id = "id"
        case location = "location"
        case name = "name"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        company = try values.decodeIfPresent(CompanyObj.self, forKey: .company)
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

//Note: CompanyObj varies between type String and String Array sent from the API
enum CompanyObj: Codable {
    var strVal: String? {
        switch self {
        case .stringArray(let value): return value.joined(separator: ", ")
        case .string(let value): return value
        }
    }
    
    func encode(to encoder: Encoder) throws {
        print("Encodeable Entered")
    }
    
    case stringArray([String]), string(String)
    
    init(from decoder: Decoder) throws {
        if let stringArray = try? decoder.singleValueContainer().decode([String].self) {
            self = .stringArray(stringArray)
            return
        }
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        throw ParsingError.missingValue
    }
    enum ParsingError:Error {
        case missingValue
    }
}

