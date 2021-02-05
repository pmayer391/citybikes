//
//  MainVC.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/5/21.
//

import Foundation

public struct CityBikeData : Codable {
	let networks : [Networks]?

	enum CodingKeys: String, CodingKey {

		case networks = "networks"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		networks = try values.decodeIfPresent([Networks].self, forKey: .networks)
	}

}
