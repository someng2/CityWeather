//
//  WeeklyWeatherCell.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import UIKit
import SnapKit

class WeeklyWeatherCell: UICollectionViewCell {
    var dayLabel: UILabel!
    var weatherIconView: UIImageView!
    var minTmpLabel: UILabel!
    var maxTmpLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    private func setupUI() {
        dayLabel = UILabel()
        dayLabel.textColor = .white
        dayLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        weatherIconView = UIImageView()
        weatherIconView  = UIImageView(frame:CGRectMake(0, 0, 40, 40));
        contentView.addSubview(weatherIconView)
        weatherIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(90)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        maxTmpLabel = UILabel()
        maxTmpLabel.textColor = .white
        maxTmpLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(maxTmpLabel)
        maxTmpLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        minTmpLabel = UILabel()
        minTmpLabel.textColor = .white.withAlphaComponent(0.7)
        minTmpLabel.font = .systemFont(ofSize: 17)
        contentView.addSubview(minTmpLabel)
        minTmpLabel.snp.makeConstraints { make in
            make.trailing.equalTo(maxTmpLabel.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(_ data: WeeklyWeather) {
        dayLabel.text = data.day
        weatherIconView.image = UIImage(named: data.weather)
        minTmpLabel.text = "최소: \(data.minTmp)°"
        maxTmpLabel.text = "최대: \(data.maxTmp)°"
    }
}
