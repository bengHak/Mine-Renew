//
//  PathUtils.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/11/08.
//

import Foundation
import CoreLocation

struct PathUtils {
    /// 제일 서쪽에 있는 좌표의 x를 0으로 설정 -> xDiff
    /// 제일 북쪽에 있는 좌표의 y를 0으로 설정 -> yDiff
    static func getFramePosition(with paths: [CLLocationCoordinate2D]) -> [CGPoint] {
        guard let xDiff: Double = paths.sorted(by: { $0.longitude < $1.longitude }).first?.longitude.datatypeValue,
              let yDiff: Double = paths.sorted(by: { $0.latitude < $1.latitude }).first?.latitude.datatypeValue else {
                return []
            }
        return paths.map { CGPoint(x: $0.longitude.datatypeValue - xDiff, y: $0.latitude.datatypeValue - yDiff) }
    }
}
