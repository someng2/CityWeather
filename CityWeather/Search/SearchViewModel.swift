//
//  SearchViewModel.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import Foundation
import RxSwift

final class SearchViewModel {
    
    var cityList = BehaviorSubject<[CityData]?>(value: [])
    
    func getCityData(filter: String) {
        let fileName = "citylist"
        let fileType = "json"
        
        guard let jsonPath = Bundle.main.path(forResource: fileName, ofType: fileType) else { return }
//        print("---> jsonPath: \(String(describing: jsonPath))")
        
        guard let jsonString = try? String(contentsOfFile: jsonPath) else { return }
    
        let data = jsonString.data(using: .utf8)
        if let jsonData = data {
            let jsonArray = try! JSONDecoder().decode([CityData].self, from: jsonData)
            if filter == "" {
                cityList.onNext(jsonArray)
            } else {
                let filteredData = jsonArray.filter { $0.name.lowercased().contains(filter.lowercased()) }
                cityList.onNext(filteredData)
                //            print("--> filteredData: \(filteredData)")
            }
        }
    }
}
