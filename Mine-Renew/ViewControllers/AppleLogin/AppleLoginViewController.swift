//
//  AppleLoginViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/11.
//

import UIKit

final class AppleLoginViewController: UIViewController {
    // MARK: - UI properties
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    // MARK: - Helpers
    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
