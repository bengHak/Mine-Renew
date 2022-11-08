//
//  HistoryViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/10/30.
//

import UIKit
import RxSwift

final class HistoryViewController: UIViewController {
    // MARK: - UI properties
    private var collectionview: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private var historyList: [PathPolygon] = []
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        fetchProfile()
    }
    
    // MARK: - IBActions
    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Helpers
    private func configureSubviews() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 350, height: 60)
        layout.minimumInteritemSpacing = 10
        collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let cellIdentifier: String = HistoryCollectionViewCell.identifier
        let nibName = UINib(nibName: cellIdentifier, bundle: nil)
        collectionview.register(nibName, forCellWithReuseIdentifier: cellIdentifier)
        collectionview.dataSource = self
        collectionview.backgroundColor = .clear
        view.addSubview(collectionview)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            collectionview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchProfile() {
        Backend.shared.requestProfile { [weak self] profile in
            guard let self,
                  let uuidString: String = profile?.uuid else { return }
            self.fetchHistory(uuidString)
        }
    }
    
    private func fetchHistory(_ profileUUID: String) {
        Backend.shared.requestWalkingHistory(profileUUID)
            .subscribe(onSuccess: { [weak self] polygonList in
                guard let self else { return }
                self.historyList = polygonList.sorted(by: { polygon1, polygon2 in
                    guard let p1Date = polygon1.createdAt?.foundationDate,
                          let p2Date = polygon2.createdAt?.foundationDate else {
                        return true
                    }
                    return p1Date > p2Date
                })
                DispatchQueue.main.async {
                    self.collectionview.reloadData()
                }
            }).disposed(by: disposeBag)
    }
}

extension HistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        historyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionview.dequeueReusableCell(withReuseIdentifier: HistoryCollectionViewCell.identifier, for: indexPath) as? HistoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setData(historyList[indexPath.row])
        return cell
    }
}
