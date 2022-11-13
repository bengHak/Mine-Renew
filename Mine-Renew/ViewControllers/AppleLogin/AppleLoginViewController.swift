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
        Backend.shared.accessCredential() { [weak self] success in
            guard success else { return }
            if success {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let unsubscribeToken else { return }
        Amplify.Hub.removeListener(unsubscribeToken)
        self.unsubscribeToken = nil
    }
    
    // MARK: - IBAction
    @IBAction func didTapAppleLogin(_ sender: Any) {
        Backend.shared.signIn(self.view.window!)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func listenAuthEvent() {
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
    
    private func requestProfile() {
        Backend.shared.requestProfile { [weak self] profile in
            if profile != nil {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self?.pushViewControllerWithStoryBoard(.nickname)
                }
            }
        }
    }
    
    private func bind() {
        $isSignedIn.sink { [weak self] success in
            guard let success, success else {
                return
            }
            self?.requestProfile()
        }.store(in: &subscriptions)
    }
}
