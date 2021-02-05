//
//  NetworkService.swift
//  Control4WeatherApp
//
//  Created by APRIL MAYER on 2/4/21.
//

import Foundation

class NetworkService{
    static let shared = NetworkService()
    
//    //MARK: - API Calls
//    func getWeatherData(_ handler: @escaping WeatherAPIHandler){
//        guard let url = URL(string: "https://samples.openweathermap.org/data/2.5/weather?lat=35&lon=139&appid=b1b15e88fa797225412429c1c50c122a1") else {return handler(nil, "Bad URL String")}
//        let request = URLRequest(url:url)
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if error == nil, let data = data{
//                let weatherData = self.parseWeatherData(data)
//                handler(weatherData, nil)
//            } else {
//                handler(nil, "API Call Failed")
//            }
//        }.resume()
//    }
//
//    //MARK: - JSON PARSERS
//    private func parseWeatherData(_ data: Data) -> WeatherData? {
//        let decoder = JSONDecoder()
//        do {
//            return try decoder.decode(WeatherData.self, from: data)
//        } catch {
//            debugPrint(error)
//        }
//        return nil
//    }
}
