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
            Image("background-main-splash")
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

                Text("하나씩 이루어가는 습관,")
                    .font(.pretendard(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 51)

                Text("지금 하루와 함께하자!")
                    .font(.pretendard(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 13)

                Image("character-main")
                    .padding(.top, 100)

                Spacer()
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

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(isLoggedIn: .constant(false))
    }
}
