//
//  SplashView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/19.
//

import SwiftUI

struct SplashView: View {
    @Binding var isLoggedIn: Bool
    @StateObject var authViewModel: AuthViewModel = .init()

    var body: some View {
        ZStack {
            Image("background-main")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Image("logo")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 168.33, height: 84.74)
                    .foregroundColor(Color(0xffffff))
                    .padding(.top, 55)

                Spacer()
            }
            .overlay {
                Image("character-main")
            }
        }
        .onAppear {
            // keyChain에 존재하는 accessToken을 통해 하루 서버에 인증
            authViewModel.validateUserByHaruServer { isLoggedIn in
                self.isLoggedIn = isLoggedIn
            }
        }
    }
}
