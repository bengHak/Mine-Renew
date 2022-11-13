//
//  Date+Ext.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/11/09.
//

import Foundation

extension Date {
    static func getMonday(myDate: Date) -> Date {
        if Calendar.current.component(.weekday, from: myDate) == 1 {
            let yesterday: Date = .init(timeIntervalSince1970: myDate.timeIntervalSince1970 - 24*60*60)
            return Date.getMonday(myDate: yesterday)
        }
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 2 // 월요일
        let mondayInWeek = cal.date(from: comps)!
        return mondayInWeek
    }
    
    static func getSunday(myDate: Date) -> Date {
        if Calendar.current.component(.weekday, from: myDate) == 1 {
            return myDate
        }
        let nextWeekDate: Date = .init(timeIntervalSince1970: myDate.timeIntervalSince1970 + 7*24*60*60)
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: nextWeekDate)
        comps.weekday = 1 // 일요일
        let sunday = cal.date(from: comps)!
        return sunday
    }
}
