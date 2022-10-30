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
import AWSDataStorePlugin

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
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
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
                    print("Successfully created polygon: \(data)")
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
            MineUser.self,
            sort: .by(.ascending(MineUser.keys.totalArea)),
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
    
    func requestProfile(completion: @escaping (MyProfile?)->()) {
        Amplify.API.query(request: .list(MyProfile.self)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully retrieved list of Profile")
                    completion(data.first)
                case .failure(let error):
                    print("Can not retrieve result : error  \(error.errorDescription)")
                    completion(nil)
                }
            case .failure(let error):
                print("Can not retrieve Notes : error \(error)")
                completion(nil)
            }
        }
    }
    
    func requestUserData(with uuid: String, completion: @escaping (MineUser?)->()) {
        let user = MineUser.keys
        let predicate = user.profileUuid == uuid
        Amplify.API.query(request: .list(MineUser.self, where: predicate)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully retrieved list of MineUser")
                    completion(data.first)
                case .failure(let error):
                    print("Can not retrieve result : error  \(error.errorDescription)")
                    completion(nil)
                }
            case .failure(let error):
                print("Can not retrieve Notes : error \(error)")
                completion(nil)
            }
        }
    }
    
    func addMyProfile(_ profile: MyProfile, completion: @escaping (Bool)->()) {
        Amplify.API.mutate(request: .create(profile)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully created Profile: \(data)")
                    completion(true)
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    completion(false)
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                completion(false)
            }
        }
    }
    
    func addMineUser(_ user: MineUser, completion: @escaping (MineUser?)->()) {
        Amplify.API.mutate(request: .create(user)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully created User: \(data)")
                    completion(data)
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    completion(nil)
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                completion(nil)
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
    
    func signOutGlobally(_ completion: @escaping ()->()) {
        Amplify.Auth.signOut(options: .init(globalSignOut: true)) { result in
            switch result {
            case .success:
                print("Successfully signed out")
                completion()
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    func deleteUser(_ completion: @escaping ()->()) {
        Amplify.Auth.deleteUser()
        completion()
    }
    
    func accessCredential(_ completion: @escaping (Bool)->()) {
        Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()
                
                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    let identityId = try identityProvider.getIdentityId().get()
//                    print("User sub - \(usersub) and identity id \(identityId)")
                }
                
                // Get AWS credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
//                    print("Access key - \(credentials.accessKey) ")
                }
                
                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
//                    print("Id token - \(tokens.idToken) ")
                }
                completion(true)
            } catch {
                print("Fetch auth session failed with error - \(error)")
                completion(false)
            }
        }
    }
}
