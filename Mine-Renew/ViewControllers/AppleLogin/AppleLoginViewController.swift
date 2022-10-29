//
//  AppleLoginViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/11.
//

import UIKit
import Amplify
import AWSPluginsCore

final class AppleLoginViewController: UIViewController {
    // MARK: - UI properties
    
    // MARK: - Properties
    private var unsubscribeToken: UnsubscribeToken?
    private let backend = Backend.shared
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        listenAuthEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backend.accessCredential()
    }
    
    // MARK: - IBAction
    @IBAction func didTapAppleLogin(_ sender: Any) {
        backend.signIn(self.view.window!)
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
                DispatchQueue.main.async {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            case HubPayload.EventName.Auth.sessionExpired:
                print("Session expired")
                // Re-authenticate the user
                
            case HubPayload.EventName.Auth.signedOut:
                print("User signed out")
                // Update UI
                
            case HubPayload.EventName.Auth.userDeleted:
                print("User deleted")
                // Update UI
            default:
                break
            }
        }
    }
    
//    func accessCredential() {
//        Amplify.Auth.fetchAuthSession { [weak self] result in
//            do {
//                let session = try result.get()
//                
//                // Get user sub or identity id
//                if let identityProvider = session as? AuthCognitoIdentityProvider {
//                    let usersub = try identityProvider.getUserSub().get()
//                    let identityId = try identityProvider.getIdentityId().get()
//                    print("User sub - \(usersub) and identity id \(identityId)")
//                }
//                
//                // Get AWS credentials
//                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
//                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
//                    print("Access key - \(credentials.accessKey) ")
//                }
//                
//                // Get cognito user pool token
//                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
//                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
//                    print("Id token - \(tokens.idToken) ")
//                }
//                DispatchQueue.main.async {
//                    self?.navigationController?.popToRootViewController(animated: true)
//                }
//            } catch {
//                print("Fetch auth session failed with error - \(error)")
//            }
//        }
//    }
}
