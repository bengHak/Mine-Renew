//
//  HistoryCollectionViewCell.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/11/08.
//

import UIKit

final class HistoryCollectionViewCell: UICollectionViewCell {
    // MARK: - UI properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "HistoryCollectionViewCell"
    
    // MARK: - Lifecycles
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = nil
        areaLabel.text = nil
    }
    
    // MARK: - Helpers
    func setData(_ data: PathPolygon) {
        if let date = data.createdAt?.foundationDate {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.locale = .init(identifier: "ko_KR")
            timeLabel.text = dateFormatter.string(from: date)
        }

        if data.area < 1000000 {
            areaLabel.text = "\(String(format: "%.2f", data.area))m²"
        } else {
            areaLabel.text = "\(String(format: "%.2f", data.area/1000000))km²"
        }
        
    }
}
