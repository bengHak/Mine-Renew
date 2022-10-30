//
//  RankViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/10/30.
//

import UIKit

final class RankViewController: UIViewController {
    // MARK: - UI properties
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBActions
    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers

}

