//
//  IndicatorView.swift
//  MyNetflix
//
//  Created by 김민석 on 2022/10/27.
//

import UIKit

class IndicatorView {
    static let shared = IndicatorView()
        
    let containerView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    
    func show() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.containerView.frame = window.frame
        self.containerView.center = window.center
        self.containerView.backgroundColor = .clear
        self.containerView.addSubview(self.activityIndicator)
        UIApplication.shared.windows.first?.addSubview(self.containerView)
    }
    
    func showIndicator() {
        self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.activityIndicator.style = .large
        self.activityIndicator.color = UIColor.white.withAlphaComponent(1)
        self.activityIndicator.center = self.containerView.center
        
        self.activityIndicator.startAnimating()
    }
    
    func dismiss() {
        self.activityIndicator.stopAnimating()
        self.containerView.removeFromSuperview()
    }
}
