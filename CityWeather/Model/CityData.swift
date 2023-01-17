//
//  CityData.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/17.
//

import Foundation

struct CityData: Codable, Hashable {
    let id: Int64
    let name: String
    let country: String
    let coord: Coord
    
    static func == (lhs: CityData, rhs: CityData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}
