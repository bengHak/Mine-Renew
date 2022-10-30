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
        Backend.shared.accessCredential() { [weak self] isSignedIn in
            guard isSignedIn else { return }
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func didTapAppleLogin(_ sender: Any) {
        Backend.shared.signIn(self.view.window!)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Helpers
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
    
    func bind() {
        $isSignedIn.sink { [weak self] success in
            guard let success else { return }
            if success {
                DispatchQueue.main.async {
#warning("로그인 이후에 MyProfile이 0개인지 확인")
#warning("0개면 nicknameVC push 하기")
#warning("1개면 main으로 가기")
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.store(in: &subscriptions)
    }
}
