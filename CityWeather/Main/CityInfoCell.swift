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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpCell()
    }
    
    private func setUpCell() {
        cityNameLabel = UILabel()
        cityNameLabel.textColor = .blue
        cityNameLabel.font = .systemFont(ofSize: 35, weight: .bold)
        contentView.addSubview(cityNameLabel)
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(_ item: City) {
        cityNameLabel.text = item.name
    }
}
