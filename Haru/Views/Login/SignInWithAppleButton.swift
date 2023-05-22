//
//  SignInWithAppleButton.swift
//  Haru
//
//  Created by 이민재 on 2023/05/19.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: UIViewRepresentable {
    @Binding var isLoggedIn: Bool
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate {
        var parent: SignInWithAppleButton

        init(_ parent: SignInWithAppleButton) {
            self.parent = parent
        }

        @objc func buttonTapped() {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                
                if let authCodeData = appleIDCredential.authorizationCode,
                    let authCode = String(data: authCodeData, encoding: .utf8) {
                    AuthService().validateAppleUserWithAuthCode(authCode: authCode) { result in
                        switch result {
                        case .success(let data):
                            print("Data: \(data)")
                            
                            // Save the tokens
                            let accessTokenData = Data(data.data.accessToken.utf8)
                            let refreshTokenData = Data(data.data.refreshToken.utf8)
                            
                            let _ = KeychainService.save(key: "accessToken", data: accessTokenData)
                            let _ = KeychainService.save(key: "refreshToken", data: refreshTokenData)
                            
                            Global.shared.me = Me(
                                id: data.data.id
                            )
                            
                            DispatchQueue.main.async {
                                self.parent.isLoggedIn = true // Set isLoggedIn to true on successful login
                            }
                            
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error
        }
    }
}
