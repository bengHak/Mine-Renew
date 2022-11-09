//
//  RankCollectionViewCell.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/11/09.
//

import UIKit

final class RankCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI properties
    private let rankLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    static let identifier: String = "RankCollectionViewCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        self.layer.cornerRadius = 13
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.backgroundColor = .white.withAlphaComponent(0.5)
        
        addSubview(nameLabel)
        addSubview(rankLabel)
        
        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            rankLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 20),
            
            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 30),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func setData(_ rank: Int, _ user: MineUser) {
        rankLabel.text = "\(rank)"
        nameLabel.text = user.name
    }
}
