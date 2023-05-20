//
//  AuthViewModel.swift
//  Haru
//
//  Created by 이민재 on 2023/05/19.
//

import Alamofire
import Foundation
import KakaoSDKAuth
import KakaoSDKUser

class AuthViewModel: ObservableObject {
    private let authService: AuthService = .init()

    func validateUserByHaruServer(completion: @escaping (Bool) -> Void) {
        if let accessTokenData = KeychainService.load(key: "accessToken"),
           let refreshTokenData = KeychainService.load(key: "refreshToken"),
           let accessToken = String(data: accessTokenData, encoding: .utf8),
           let refreshToken = String(data: refreshTokenData, encoding: .utf8)
        {
            let headers: HTTPHeaders = [
                "accessToken": accessToken,
                "refreshToken": refreshToken
            ]
            authService.validateUser(headers: headers) { result in
                switch result {
                case .success(let data):
                    print("UserVerifyResponse: \(data)")

                    // Save the ID and new access token into Keychain
                    Global.shared.user = User(
                        id: data.data.id,
                        name: "loggedInUser",
                        introduction: "loggedInUser",
                        postCount: 0,
                        followerCount: 0,
                        followingCount: 0,
                        isFollowing: false
                    )
                    _ = KeychainService.save(key: "accessToken", data: data.data.accessToken.data(using: .utf8)!)
                    completion(true)
                case .failure(let error):
                    print("Error: \(error)")
                    completion(false)
                }
            }
        } else {
            print("No data found in Keychain for these keys or tokens are nil.")
            completion(false)
        }
    }

    func handleKakaoLogin(completion: @escaping (Bool) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                self.handleLoginResponse(oauthToken: oauthToken, error: error, completion: completion)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                self.handleLoginResponse(oauthToken: oauthToken, error: error, completion: completion)
            }
        }
    }

    private func handleLoginResponse(oauthToken: OAuthToken?, error: Error?, completion: @escaping (Bool) -> Void) {
        if let error = error {
            print(error)
            completion(false)
        } else {
            print("Kakao login success.")

            guard let oauthToken = oauthToken else {
                print("OAuthToken is nil")
                completion(false)
                return
            }

            authService.validateKakaoUserWithToken(token: oauthToken.accessToken) { result in
                switch result {
                case .success(let data):
                    print(data)

                    // Save the tokens
                    let accessTokenData = Data(data.data.accessToken.utf8)
                    let refreshTokenData = Data(data.data.refreshToken.utf8)

                    _ = KeychainService.save(key: "accessToken", data: accessTokenData)
                    _ = KeychainService.save(key: "refreshToken", data: refreshTokenData)

                    UserApi.shared.me { user, error in
                        if let error = error {
                            print("Error fetching user email from Kakao", error)
                            completion(false)
                        } else if let user = user {
//                            let email = user.kakaoAccount?.email ?? ""
                            Global.shared.user = User(
                                id: data.data.id,
                                name: "loggedInUser",
                                introduction: "loggedInUser",
                                postCount: 0,
                                followerCount: 0,
                                followingCount: 0,
                                isFollowing: false
                            )
                            completion(true)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
        }
    }
}
