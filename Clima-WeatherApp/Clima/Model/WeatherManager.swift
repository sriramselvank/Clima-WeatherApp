//
//  WeatherManager.swift
//  Clima
//
//  Created by ShreeThaanu on 06/12/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)
    func didFailWithError(error : Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=dc1769d1fe20caeef2727474a080fb10&units=metric"
    
    var weatherDelegate : WeatherManagerDelegate?
    
    func fetchWeather(latitude : CLLocationDegrees, longtitude : CLLocationDegrees){
        
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longtitude)"
        
        performRequest(with : urlString)
        
    }
    
    func fetchWeather(cityName : String){
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        performRequest(with : urlString)
        
    }
    
    func performRequest(with urlString : String){
        
        //1. create a URL
        if let url = URL(string: urlString) {
            
            //2. create URL session
            let session = URLSession.shared
            
            //3. Give session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.weatherDelegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safedata = data {
                    if let weather = self.parseJson(safedata){
                        DispatchQueue.main.async {
                            
                            self.weatherDelegate?.didUpdateWeather(self, weather : weather)
                        }
                    }
                }
            }
            
            //4. start a task
            task.resume()
        }
    }
    
    func parseJson(_ weatherData : Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        
        do{
            
            let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
            
        } catch {
            weatherDelegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}


