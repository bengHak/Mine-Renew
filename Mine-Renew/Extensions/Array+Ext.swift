//
//  Array+Ext.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/11/09.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        // iOS 9 or later
        return indices ~= index ? self[index] : nil
        // iOS 8 or earlier
        // return startIndex <= index && index < endIndex ? self[index] : nil
        // return 0 <= index && index < self.count ? self[index] : nil
    }
}
