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
    var hourlyWeather = PublishSubject<[HourlyWeather]?>()
    var weeklyWeather = PublishSubject<[WeeklyWeather]?>()
    
    init() {
        self.city = CityData(id: 1839726, name: "Asan", country: "KR", coord: Coord(lon: 127.004173, lat: 36.783611))
    }
    
    func getWeatherData() {
//        let now = Date()
//        print("now: \(now)")
        
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
                    let data = try decoder.decode(WeatherData.self, from: result)
                    self.weather.onNext(data)
                    self.parseWeather(data)
//                    print("data: \(data)")
                } catch {
                    print("error!\(error)")
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseWeather(_ data: WeatherData) {
        var hourlyList: [HourlyWeather] = []
        var weeklyList: [WeeklyWeather] = []
        let weatherList = data.list
        let dayList = ["일", "월", "화", "수", "목", "금", "토"]
        var dayCount = 0
        var hourCount = 0
        var date = weatherList[0].dt_txt.prefix(10)
        var dayInt = getDay(String(date))
        var weeklyWeather = WeeklyWeather(
            day: "오늘",
            weather: weatherList[0].weather[0].icon,
            minTmp: Int(round(weatherList[0].main.temp_min)),
            maxTmp: Int(round(weatherList[0].main.temp_max))
        )
        var hourlyWeather = HourlyWeather(hour: "지금", weather: "", temparature: 0)
        
        weatherList.forEach { weather in
            if date < weather.dt_txt.prefix(10) {
                weeklyList.append(weeklyWeather)
                dayCount += 1
                date = weather.dt_txt.prefix(10)
                dayInt += 1
                let now = (dayInt-1)%7
                weeklyWeather = WeeklyWeather(day: (dayList[now]), weather: "", minTmp: 100, maxTmp: 0)
            }
            if dayCount < 5 {
                if weather.dt_txt.suffix(8) == "15:00:00" {
                    weeklyWeather.weather = weather.weather[0].icon
                }
                weeklyWeather.maxTmp = max(weeklyWeather.maxTmp, Int(round(weather.main.temp_max)))
                weeklyWeather.minTmp = min(weeklyWeather.minTmp, Int(round(weather.main.temp_min)))
            }
            if dayCount <= 1 {
                if hourCount > 0 {
                    hourlyWeather.hour = "\(weather.dt_txt.suffix(8).prefix(2))시"
                }
                hourlyWeather.weather = weather.weather[0].icon
                hourlyWeather.temparature = Int(round(weather.main.temp))
                hourCount += 1
                hourlyList.append(hourlyWeather)
            }
        }
        self.weeklyWeather.onNext(weeklyList)
        self.hourlyWeather.onNext(hourlyList)
    }
    
    private func getDay(_ str: String) -> Int{
        let cal = Calendar(identifier: .gregorian)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd일"
        let date = formatter.date(from: str)!
        let comps = cal.dateComponents([.weekday], from: date)
        
        return comps.weekday!
    }
}
