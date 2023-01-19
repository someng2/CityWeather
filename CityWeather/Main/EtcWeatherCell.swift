//
//  EtcWeatherCell.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/19.
//

import UIKit

class EtcWeatherCell: UICollectionViewCell {
    var categoryLabel: UILabel!
    var valueLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    private func setupUI() {
        categoryLabel = UILabel()
        categoryLabel.textColor = .white.withAlphaComponent(0.7)
        categoryLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
        }
        
        valueLabel = UILabel()
        valueLabel.textColor = .white
        valueLabel.font = .systemFont(ofSize: 35)
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(_ data: EtcWeather) {
        categoryLabel.text = data.category
        valueLabel.text = data.value
    }
}
