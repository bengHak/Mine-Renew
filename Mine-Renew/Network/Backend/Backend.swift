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
import RxSwift

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
    
    func uploadWalkingPath(_ walkingPath: WalkingCoordinate) -> Single<Bool> {
        Single<Bool>.create { single -> Disposable in
            Amplify.API.mutate(request: .create(walkingPath)) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success:
                        single(.success(true))
                    case .failure(let error):
                        print("Got failed result with \(error.errorDescription)")
                        single(.failure(error))
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    @discardableResult
    func asyncUploadWalkingPath(_ walkingPath: WalkingCoordinate) async -> Bool {
        await withCheckedContinuation { continuation in
            Amplify.API.mutate(request: .create(walkingPath)) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success:
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("Got failed result with \(error.errorDescription)")
                        continuation.resume(returning: false)
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func asyncUploadPathPolygon(_ polygon: PathPolygon) async -> Bool {
        await withCheckedContinuation { continuation in
            Amplify.API.mutate(request: .create(polygon)) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let data):
                        print("Successfully created polygon: \(data)")
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("Got failed result with \(error.errorDescription)")
                        continuation.resume(returning: false)
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func requestWalkingHistory(_ userUuid: String) -> Single<[PathPolygon]> {
        Single<[PathPolygon]>.create { single -> Disposable in
            Amplify.API.query(
                request: .list(PathPolygon.self, where: PathPolygon.keys.userId == userUuid)
            ) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let polygonList):
                        print("Successfully retrieved list of Users")
                        print(polygonList)
                        single(.success(polygonList))
                    case .failure(let error):
                        print("Can not retrieve result : error  \(error.errorDescription)")
                        single(.failure(error))
                    }
                case .failure(let error):
                    print("Can not retrieve Notes : error \(error)")
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func requestRanking() -> Single<[MineUser]> {
        Single<[MineUser]>.create { single -> Disposable in
            Amplify.DataStore.query(
                MineUser.self,
                sort: .by(.ascending(MineUser.keys.totalArea)),
                paginate: .page(0, limit: 20)
            ) {
                switch $0 {
                case .success(let result):
                    print("Users: \(result)")
                    single(.success(result))
                case .failure(let error):
                    print("Error listing User - \(error.localizedDescription)")
                    single(.failure(error))
                }
            }
            return Disposables.create()
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
    
    func asyncRequestProfile() async -> MyProfile? {
        await withCheckedContinuation { continuation in
            Amplify.API.query(request: .list(MyProfile.self)) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let data):
                        print("Successfully retrieved list of Profile")
                        continuation.resume(returning: data.first)
                    case .failure(let error):
                        print("Can not retrieve result : error  \(error.errorDescription)")
                        continuation.resume(returning: nil)
                    }
                case .failure(let error):
                    print("Can not retrieve Notes : error \(error)")
                    continuation.resume(returning: nil)
                }
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
