//
//  MainViewModel.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/17.
//

import Foundation
import Alamofire
import RxSwift

final class MainViewModel {
    
    var city: CityData
    var weather = PublishSubject<WeatherData?>()
    
    init() {
        self.city = CityData(id: 1839726, name: "Asan", country: "KR", coord: Coord(lon: 127.004173, lat: 36.783611))
    }
    
    func getWeatherData() {
        let now = Date()
        print("now: \(now)")
        
        let url = "https://api.openweathermap.org/data/2.5/forecast?lat=\(city.coord.lat)&lon=\(city.coord.lon)&appid=607fbd405599430259f383826c9a702d"
        
        AF.request(url,
                   method: .get,
                   parameters: ["lang":"kr", "units":"metric"],
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success:
                guard let result = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    self.weather.onNext(try decoder.decode(WeatherData.self, from: result))
                    //                print("---> weather Data: \(self.weather)")
                    //                if data.result == 2000{
                    //                    completion(data.data)
                    //                }
                } catch {
                    print("error!\(error)")
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

            
    }
}
