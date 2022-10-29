//
//  Backend.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/11.
//
import UIKit
import Amplify
import AWSPluginsCore
import AWSCognitoAuthPlugin
import AWSAPIPlugin

class Backend {
    static let shared = Backend()
    static func initialize() -> Backend {
        return .shared
    }

    private init() {
        // initialize amplify
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.configure()
            print("Initialized Amplify");
        } catch {
            print("Could not initialize Amplify: \(error)")
        }
    }
    
    func uploadWalkingPath(_ polygon: PathPolygon) {
        Amplify.API.mutate(request: .create(polygon)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully created User: \(data)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
    }
    
    func requestWalkingHistory(_ userUuid: String) {
        Amplify.API.query(
            request: .list(PathPolygon.self, where: PathPolygon.keys.uuid == userUuid)
        ) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let polygonList):
                    print("Successfully retrieved list of Users")
                    print(polygonList)
                case .failure(let error):
                    print("Can not retrieve result : error  \(error.errorDescription)")
                }
            case .failure(let error):
                print("Can not retrieve Notes : error \(error)")
            }
        }
    }
    
    func requestRanking() {
        Amplify.DataStore.query(
            User.self,
            sort: .by(.ascending(User.keys.totalArea)),
            paginate: .page(0, limit: 20)
        ) {
            switch $0 {
            case .success(let result):
                print("Users: \(result)")
            case .failure(let error):
                print("Error listing User - \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Auth
extension Backend {
    func fetchAttributes() {
        Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                print("User attributes - \(attributes)")
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
            }
        }
    }
    
    func signIn(_ window: UIWindow) {
        Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: window) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    func signOutGlobally() {
        Amplify.Auth.signOut(options: .init(globalSignOut: true)) { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    func deleteUser() async {
        do {
            try await Amplify.Auth.deleteUser()
            print("Successfully deleted user")
        } catch let error as AuthError {
            print("Delete user failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func accessCredential() {
        Amplify.Auth.fetchAuthSession { [weak self] result in
            do {
                let session = try result.get()
                
                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    let identityId = try identityProvider.getIdentityId().get()
                    print("User sub - \(usersub) and identity id \(identityId)")
                }
                
                // Get AWS credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                    print("Access key - \(credentials.accessKey) ")
                }
                
                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    print("Id token - \(tokens.idToken) ")
                }
                #warning("completion handler로 보내기")
//                DispatchQueue.main.async {
//                    self?.navigationController?.popToRootViewController(animated: true)
//                }
            } catch {
                print("Fetch auth session failed with error - \(error)")
            }
        }
    }
}
