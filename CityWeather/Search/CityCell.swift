//
//  CityCell.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/19.
//

import UIKit
import SnapKit

class CityCell: UICollectionViewCell {
    var cityLabel: UILabel!
    var countryLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    private func setupUI() {
        cityLabel = UILabel()
        cityLabel.font = .systemFont(ofSize: 15, weight: .bold)
        cityLabel.textColor = .white
        contentView.addSubview(cityLabel)
        cityLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.leading.equalToSuperview()
        }
        
        countryLabel = UILabel()
        countryLabel.font = .systemFont(ofSize: 15)
        countryLabel.textColor = .white
        contentView.addSubview(countryLabel)
        countryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(15)
            make.leading.equalToSuperview()
        }
    }
    
    func configure(_ item: CityData) {
        cityLabel.text = item.name
        countryLabel.text = item.country
    }
}
