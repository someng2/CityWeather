//
//  HourlyWeatherCell.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import UIKit
import SnapKit

class HourlyWeatherCell: UICollectionViewCell {
    var hourLabel: UILabel!
    var weatherIconView: UIImageView!
    var tmpLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    private func setupUI() {
        hourLabel = UILabel()
        hourLabel.font = .systemFont(ofSize: 14)
        hourLabel.textColor = .white
        contentView.addSubview(hourLabel)
        hourLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        weatherIconView = UIImageView()
        weatherIconView  = UIImageView(frame:CGRectMake(0, 0, 40, 40));
        contentView.addSubview(weatherIconView)
        weatherIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        tmpLabel = UILabel()
        tmpLabel.font = .systemFont(ofSize: 15)
        tmpLabel.textColor = .white
        contentView.addSubview(tmpLabel)
        tmpLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(_ item: HourlyWeather) {
        hourLabel.text = item.hour
        weatherIconView.image = UIImage(named: item.weather)
        tmpLabel.text = "\(item.temparature)°"
    }
}
