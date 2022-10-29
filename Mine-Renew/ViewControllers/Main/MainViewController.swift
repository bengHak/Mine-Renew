//
//  ViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/09.
//

import UIKit
import Lottie
import Amplify
import AWSPluginsCore

final class MainViewController: UIViewController {
    
    // MARK: - UI properties
    private let mineLottie = AnimationView(name: "Mine")
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAuthNoti()
        mineLottie.loopMode = .loop
        mineLottie.play()
    }

    // MARK: - IBAction
    @IBAction func deleteUser(_ sender: Any) {
        Amplify.Auth.deleteUser()
    }

    @IBAction func didTapRank(_ sender: Any) {
        print("did tap rank")
    }

    @IBAction func didTapSignOut(_ sender: Any) {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }

    // MARK: - Helpers
    func setupMine() {
        view.addSubview(mineLottie)
        mineLottie.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mineLottie.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mineLottie.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mineLottie.heightAnchor.constraint(equalToConstant: 250),
            mineLottie.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    func requestAuthNoti() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.showAlert()
            case .authorized:
                fallthrough
            case .denied:
                fallthrough
            case .provisional:
                fallthrough
            case .ephemeral:
                fallthrough
            @unknown default:
                return
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "알림 권한 필요", message: "산책이 완료됐을 때 알림을 보내려면 알림 권한이 필요합니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { _ in
            DispatchQueue.main.async {
                let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
                UNUserNotificationCenter.current().requestAuthorization(options: notiAuthOptions) { (success, error) in
                    if let error = error {
                        print(#function, error)
                    }
                }
            }
        }
        alert.addAction(action)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
    
}
