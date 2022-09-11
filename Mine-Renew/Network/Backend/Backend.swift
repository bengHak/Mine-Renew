//
//  Backend.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/11.
//
import UIKit
import Amplify

class Backend {
    static let shared = Backend()
    static func initialize() -> Backend {
        return .shared
    }
    private init() {
      // initialize amplify
      do {
        try Amplify.configure()
        print("Initialized Amplify");
      } catch {
        print("Could not initialize Amplify: \(error)")
      }
    }
}
