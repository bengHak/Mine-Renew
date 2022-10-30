//
//  ProfileViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/10/30.
//

import UIKit
import Amplify
import AWSPluginsCore

final class ProfileViewController: UIViewController {
    // MARK: - UI properties
    @IBOutlet weak var nicknameLabel: UILabel!
    
    // MARK: - Properties
    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfile()
    }
    
    // MARK: - IBActions
    @IBAction func deleteUser(_ sender: Any) {
        showDeleteUserAlert()
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        Backend.shared.signOutGlobally() { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Helpers
    func showDeleteUserAlert() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "정말로 탈퇴하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            Backend.shared.deleteUser() { [weak self] in
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchProfile() {
        Backend.shared.requestProfile() { [weak self] profile in
            guard let profile else { return }
            self?.fetchUserData(profile.uuid)
        }
    }
    
    private func fetchUserData(_ uuid: String) {
        Backend.shared.requestUserData(with: uuid) { [weak self] userData in
            guard let userData else { return }
            DispatchQueue.main.async {
                self?.nicknameLabel.text = userData.name
            }
        }
    }
}

