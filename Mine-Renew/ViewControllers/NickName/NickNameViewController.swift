//
//  NickNameViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/10/30.
//

import UIKit
import Amplify
import AWSPluginsCore
import Combine

final class NickNameViewController: UIViewController {
    // MARK: - UI properties
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var nicknameWarningLabel: UILabel!
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func didTapRegisterNickname(_ sender: Any) {
        createProfile()
    }
    
    // MARK: - Helpers
    func createProfile() {
        guard let nickname = nicknameTextField.text,
              !nickname.isEmpty else {
            nicknameWarningLabel.isHidden = false
            return
        }

        let profileUUID: String = UUID().uuidString
        let lastUpdate = Temporal.DateTime(Date())
        let user = MineUser(
            profileUuid: profileUUID,
            name: nickname,
            totalArea: 0,
            totalAreaLastUpdate: lastUpdate
        )
        
        Backend.shared.addMineUser(user) { [weak self] result in
            guard let result else { return }
            let myProfile = MyProfile(uuid: profileUUID, userData: result, myProfileUserDataId: result.id)
            Backend.shared.addMyProfile(myProfile) { [weak self] result in
                DispatchQueue.main.async {
                    if result {
                        self?.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self?.showSignUpFailedAlert()
                    }
                }
            }
        }
    }
    
    func showSignUpFailedAlert() {
        let alert = UIAlertController(title: "회원가입 실패", message: "회원가입에 실패했습니다.\n홈 화면으로 돌아갑니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

