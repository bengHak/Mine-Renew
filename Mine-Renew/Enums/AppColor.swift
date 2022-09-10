//
//  AppColor.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/10.
//

import UIKit

enum AppColor: String {
    case system_light_red       = "#ff3b30"
    case system_light_orange    = "#ff9500"
    case system_light_yellow    = "#ffcc00"
    case system_light_green     = "#34c759"
    case system_light_blue      = "#007aff"
    
    case junction_red           = "#e34742"
    case junction_blue          = "#3b8fec"
    case junction_green         = "#6fb872"
    case junction_second_green  = "#8dd88c"
    case junction_yellow        = "#fde28e"
    
    var color: UIColor {
        UIColor.getColorWithHex(with: self.rawValue)
    }
}
