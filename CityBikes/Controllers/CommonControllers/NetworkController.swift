//
//  NetworkController.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/4/21.
//

import Foundation

class NetworkController{
    
    static let shared = NetworkController()
    
    //MARK: - API Calls
    func getCityBikes(_ handler: @escaping CityBikesAPIHandler){
        guard let url = URL(string: "http://api.citybik.es/v2/networks") else {return handler(nil, "Bad URL String")}
        let request = URLRequest(url:url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data{
                let cityBikeData = self.parseCityBikeData(data)
                handler(cityBikeData, nil)
            } else {
                handler(nil, "API Call Failed")
                debugPrint("API ERROR: \(error?.localizedDescription ?? "")")
            }
        }.resume()
    }

    //MARK: - JSON PARSERS
    private func parseCityBikeData(_ data: Data) -> CityBikeData? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(CityBikeData.self, from: data)
        } catch {
            debugPrint("JSON ERROR: \(error.localizedDescription)")
        }
        return nil
    }
}
