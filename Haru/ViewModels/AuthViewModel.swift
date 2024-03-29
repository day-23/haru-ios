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
            AuthService.validateUser(headers: headers) { result in
                switch result {
                case .success(let data):
                    print("UserVerifyResponse: \(data)")

                    // Save the ID and new access token into Keychain
                    Dispatcher.dispatch(action: Global.Actions.setUserData, params: data, for: Global.self)
                    _ = KeychainService.save(key: "accessToken", data: data.accessToken.data(using: .utf8)!)
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

            AuthService.validateKakaoUserWithToken(token: oauthToken.accessToken) { result in
                switch result {
                case .success(let data):
                    print(data)

                    // Save the tokens
                    let accessTokenData = Data(data.data.accessToken.utf8)
                    let refreshTokenData = Data(data.data.refreshToken.utf8)

                    _ = KeychainService.save(key: "accessToken", data: accessTokenData)
                    _ = KeychainService.save(key: "refreshToken", data: refreshTokenData)

                    self.validateUserByHaruServer { isLoggedIn in
                        completion(isLoggedIn)
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
        }
    }
}
