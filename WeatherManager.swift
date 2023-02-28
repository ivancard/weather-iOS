//
//  WeatherManager.swift
//  Clima
//
//  Created by ivan cardenas on 26/02/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

protocol weatherDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=176dcfbf99aa9238c9cbf8556838df23&units=metric"

    var delegate: weatherDelegate?

    func fetchWeather(cityName: String) {
        var urlString = ""

        if cityName.contains(" ") {
            let city = cityName.replacingOccurrences(of: " ", with: "%20")
            urlString = "\(weatherURL)&q=\(city)"
        } else {
            urlString = "\(weatherURL)&q=\(cityName)"
        }
        performRequest(with: urlString)
    }

    func fetchWeather(longitude: CLLocationDegrees , latitude: CLLocationDegrees ) {
        let urlString = "\(weatherURL)&lon=\(longitude)&lat=\(latitude)"
        performRequest(with: urlString)
    }

    func performRequest(with url: String) {
        //1_ create url
        if let url = URL(string : url) {
            //2_ create urlSession
            let session = URLSession(configuration: .default)

            //3_ give the session a task
            session.dataTask(with: url) { data, urlResponse, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }.resume()
        }
    }

    func parseJSON(_ data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData: WeatherData = try  decoder.decode(WeatherData.self, from: data)

            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name

            return WeatherModel(conditionId: id, cityName: name, temperature: temp)
        } catch {
             delegate?.didFailWithError(error: error)
            return nil
        }
    }

    
}
