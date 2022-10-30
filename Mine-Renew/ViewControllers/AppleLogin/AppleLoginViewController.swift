//
//  AppleLoginViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/11.
//

import UIKit
import Amplify
import AWSPluginsCore
import Combine

final class AppleLoginViewController: UIViewController {
    // MARK: - UI properties
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var nicknameWarningLabel: UILabel!
    
    // MARK: - Properties
    private var unsubscribeToken: UnsubscribeToken?
    @Published private var isSignedIn: Bool? = nil
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        listenAuthEvent()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Backend.shared.accessCredential() { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func didTapAppleLogin(_ sender: Any) {
        guard let nickname = nicknameTextField.text,
              !nickname.isEmpty else {
            nicknameWarningLabel.isHidden = false
            return
        }

        Backend.shared.signIn(self.view.window!)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
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
    
    func listenAuthEvent() {
        unsubscribeToken = Amplify.Hub.listen(to: .auth) { [weak self] payload in
            switch payload.eventName {
            case HubPayload.EventName.Auth.signedIn:
                print("User signed in")
                self?.isSignedIn = true
            case HubPayload.EventName.Auth.sessionExpired:
                print("Session expired")
            case HubPayload.EventName.Auth.signedOut:
                print("User signed out")
            case HubPayload.EventName.Auth.userDeleted:
                print("User deleted")
            default:
                break
            }
        }
    }

    func showSignUpFailedAlert() {
        let alert = UIAlertController(title: "회원가입 실패", message: "회원가입에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func bind() {
        $isSignedIn.sink { [weak self] success in
            guard let success else { return }
            if success {
                DispatchQueue.main.async {
                    self?.createProfile()
                }
            }
        }.store(in: &subscriptions)
    }
}
