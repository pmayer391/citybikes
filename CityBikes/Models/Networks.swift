//
//  MainVC.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import Foundation

struct Networks : Codable {
	let company : [String]?
	let href : String?
	let id : String?
	let location : Location?
	let name : String?

	enum CodingKeys: String, CodingKey {

		case company = "company"
		case href = "href"
		case id = "id"
		case location = "location"
		case name = "name"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		company = try values.decodeIfPresent([String].self, forKey: .company)
		href = try values.decodeIfPresent(String.self, forKey: .href)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		location = try values.decodeIfPresent(Location.self, forKey: .location)
		name = try values.decodeIfPresent(String.self, forKey: .name)
	}

}
