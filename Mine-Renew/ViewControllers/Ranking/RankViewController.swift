//
//  RankViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/10/30.
//

import UIKit
import RxSwift

final class RankViewController: UIViewController {
    // MARK: - UI properties
    private var collectionview: UICollectionView!
    @IBOutlet weak var currentWeekLabel: UILabel!
    
    @IBOutlet weak var rankFirstImageView: UIImageView!
    @IBOutlet weak var rankSecondImageView: UIImageView!
    @IBOutlet weak var rankThirdImageView: UIImageView!
    
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    @IBOutlet weak var threeLabel: UILabel!
    @IBOutlet weak var rankFirstLabel: UILabel!
    @IBOutlet weak var rankSecondLabel: UILabel!
    @IBOutlet weak var rankThirdLabel: UILabel!

    // MARK: - Properties
    private var rankProfileList: [MineUser] = []
    private let disposeBag: DisposeBag = DisposeBag()
    private let monday: Date = Date.getMonday(myDate: Date())
    private let sunday: Date = Date.getSunday(myDate: Date())
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        fetchProfiles()
    }

    // MARK: - IBActions
    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    private func configureSubviews() {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "MM.dd"
        let mondayText: String = dateFormatter.string(from: monday)
        let sundayText: String = dateFormatter.string(from: sunday)
        currentWeekLabel.text = "\(mondayText) - \(sundayText)"
    }

    private func fetchProfiles() {
        Backend.shared.requestRanking(self.monday)
            .subscribe { [weak self] users in
                guard let self else { return }
                let sorted: [MineUser] = users.sorted(by: { $0.currentWeekTotalArea > $1.currentWeekTotalArea })
                if users.count > 20 {
                    self.rankProfileList = Array(sorted[..<20])
                } else {
                    self.rankProfileList = sorted
                }
                DispatchQueue.main.async {
                    self.setRankImageLabels()
                }
            }.disposed(by: disposeBag)
    }
    
    private func setRankImageLabels() {
        if let first = rankProfileList[safe: 0] {
            rankFirstImageView.isHidden = false
            rankFirstLabel.text = first.name
            rankFirstLabel.isHidden = false
            oneLabel.isHidden = false
        }
        
        if let second = rankProfileList[safe: 1] {
            rankSecondImageView.isHidden = false
            rankSecondLabel.text = second.name
            rankSecondLabel.isHidden = false
            twoLabel.isHidden = false
        }
        
        if let third = rankProfileList[safe: 2] {
            rankThirdImageView.isHidden = false
            rankThirdLabel.text = third.name
            rankThirdLabel.isHidden = false
            threeLabel.isHidden = false
        }
    }
}

