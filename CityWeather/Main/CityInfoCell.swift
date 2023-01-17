//
//  CityInfoCell.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/17.
//

import UIKit
import SnapKit

class CityInfoCell: UICollectionViewCell {
    var cityNameLabel: UILabel!
    var tmpLabel: UILabel!
    var descriptionLabel: UILabel!
    var minMaxTmpLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCityNameLabel()
        setUpTmpLabel()
        setUpDescriptionLabel()
        setUpMinMaxTmpLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpCityNameLabel()
        setUpTmpLabel()
        setUpDescriptionLabel()
        setUpMinMaxTmpLabel()
    }
    
    private func setUpCityNameLabel() {
        cityNameLabel = UILabel()
        cityNameLabel.textColor = .white
        cityNameLabel.font = .systemFont(ofSize: 36)
        contentView.addSubview(cityNameLabel)
        
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setUpTmpLabel() {
        tmpLabel = UILabel()
        tmpLabel.textColor = .white
        tmpLabel.font = .systemFont(ofSize: 80)
        contentView.addSubview(tmpLabel)
        
        tmpLabel.snp.makeConstraints { make in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setUpDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 30)
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(tmpLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setUpMinMaxTmpLabel() {
        minMaxTmpLabel = UILabel()
        minMaxTmpLabel.textColor = .white
        minMaxTmpLabel.font = .systemFont(ofSize: 22)
        contentView.addSubview(minMaxTmpLabel)
        
        minMaxTmpLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(_ item: WeatherData) {
        cityNameLabel.text = item.city.name
        
        let currentWeather = item.list[0]
        let tmp = Int(round(currentWeather.main.temp))
        let minTemp = Int(round(currentWeather.main.temp_min))
        let maxTemp = Int(round(currentWeather.main.temp_max))
        let description = currentWeather.weather[0].description
        
        tmpLabel.text = "\(tmp)°"
        descriptionLabel.text = description
        minMaxTmpLabel.text = "최고: \(maxTemp)°  |  최저: \(minTemp)°"
    }
}
