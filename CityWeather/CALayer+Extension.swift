//
//  CALayer+Extension.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/27.
//

import Foundation
import UIKit

extension CALayer {
    func addBorder(index: Int, edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        if index >= 4 { return }
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        border.backgroundColor = color.cgColor
        addSublayer(border)
    }
}
