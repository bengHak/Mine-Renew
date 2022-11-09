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
    
    @IBAction func didTapDeveloperInfo(_ sender: Any) {
        showDeveloperAlert()   
    }
    
    // MARK: - Helpers
    private func showDeveloperAlert() {
        let alert = UIAlertController(title: "개발자 정보", message: "📱 iOS 개발: 브로디, 토비\n⚙️ 서버: 비비\n📝 기획: 로운, 헤이든\n🎨 앱 디자인: 헤이든", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
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

