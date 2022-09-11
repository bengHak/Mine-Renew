//
//  WalkingHistory.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/10.
//

import Foundation

struct WalkingHistory: Codable {
    var date: Date

    // 걸린 시간 (단위: 초)
    var elapsedSeconds: Int
    var startingCoordinate: String
    
    // 산책 구역 면적 (단위: 제곱 미터)
    var area: Int
}
