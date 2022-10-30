//
//  UIViewController+Ext.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/10/30.
//

import UIKit

enum StoryBoardName: String {
    case profile = "ProfileViewController"
    case login = "AppleLoginViewController"
    case rank = "RankViewController"
    case history = "HistoryViewController"
    case nickname = "NickNameViewController"
}

extension UIViewController {
    func pushViewControllerWithStoryBoard(_ name: StoryBoardName) {
        let storyboard: UIStoryboard = UIStoryboard(name: name.rawValue, bundle: nil)
        if let vc: UIViewController = storyboard.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func presentFullScreenModal(_ name: StoryBoardName) {
        let storyboard: UIStoryboard = UIStoryboard(name: name.rawValue, bundle: nil)
        if let vc: UIViewController = storyboard.instantiateInitialViewController() {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    
    func initUIViewControllerWithStoryBoard(_ name: StoryBoardName) -> UIViewController? {
        let storyboard: UIStoryboard = UIStoryboard(name: name.rawValue, bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
}

