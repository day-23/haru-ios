//
//  SplashView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/19.
//

import SwiftUI

struct SplashView: View {
    @Binding var isLoggedIn: Bool
    @StateObject var authViewModel : AuthViewModel = AuthViewModel()
    
    var body: some View {
        Image("background-main")
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .overlay {
                VStack(spacing: 0) {
                    Image("haru")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color(0xffffff))
                        .frame(width: 400, height: 57)
                    Image("character-main")
                }
            }
            .onAppear {
                // keyChain에 존재하는 accessToken을 통해 하루 서버에 인증
                authViewModel.validateUserByHaruServer{ isLoggedIn in
                    self.isLoggedIn = isLoggedIn
                    print(isLoggedIn)
                }
            }
    }
}
