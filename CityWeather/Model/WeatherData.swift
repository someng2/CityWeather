//
//  WeatherData.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/17.
//

import Foundation

struct WeatherData: Codable, Hashable {
    let city: City
    let cnt: Int
    let cod: String
    let list: [WeatherInfo]
    
    static func == (lhs: WeatherData, rhs: WeatherData) -> Bool {
        lhs.city.id == rhs.city.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(city.id)
    }
}

struct City: Codable {
    let coord: Coord
    let country: String
    let id: Int64
    let name: String
    let population: Int64
    let sunrise: Int64
    let sunset: Int64
    let timezone: Int64
}

struct WeatherInfo: Codable {
    let clouds: Clouds
    let dt: Int64
    let dt_txt: String
    let main: Main
    let pop: Double
    let sys: Sys
    let visibility: Int64
    let weather: [Weather]
    let wind: Wind
}

struct Main: Codable {
    let feels_like: Double
    let grnd_level: Int64
    let humidity: Int
    let pressure: Int64
    let sea_level: Int64
    let temp: Double
    let temp_kf: Double
    let temp_max: Double
    let temp_min: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable {
    let deg: Int
    let gust: Double
    let speed: Double
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let pod: String
}
