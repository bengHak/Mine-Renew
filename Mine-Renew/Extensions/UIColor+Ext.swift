//
//  UIColor+Ext.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/10.
//

import UIKit

extension UIColor {
    static func getColorWithHex(with hex: String) -> UIColor {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        return self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
