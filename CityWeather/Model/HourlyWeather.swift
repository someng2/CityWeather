//
//  HourlyWeather.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import Foundation

struct HourlyWeather: Hashable {
    let id = UUID()
    var hour: String
    var weather: String
    var temparature: Int
}
