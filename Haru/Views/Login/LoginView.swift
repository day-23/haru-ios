//
//  LoginView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/19.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @StateObject var authViewModel: AuthViewModel = .init()

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
                        .foregroundColor(Color(0xfdfdfd))
                        .frame(width: 400, height: 57)

                    Text("나의 하루를 가치 있게 만드는 습관\n지금 하루와 함께 시작해 보세요!")
                        .font(.pretendard(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, 38)

                    Text("1초만에 간편 로그인!")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x1dafff))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color(0xfdfdfd))
                        .cornerRadius(10)
                        .padding(.top, 71)
                        .padding(.leading, 128)

                    VStack(spacing: 18) {
                        Text("카카오로 로그인하기")
                            .font(.pretendard(size: 14, weight: .bold))
                            .frame(width: 312, height: 44)
                            .background(Color(0xfee500))
                            .cornerRadius(12)
                            .onTapGesture {
                                authViewModel.handleKakaoLogin { isLoggedIn in
                                    self.isLoggedIn = isLoggedIn
                                }
                            }

//                        Text("APPLE로 로그인하기")
//                            .font(.pretendard(size: 14, weight: .bold))
//                            .foregroundColor(.white)
//                            .frame(width: 312, height: 44)
//                            .background(Color(0x000000))
//                            .cornerRadius(12)
//                            .onTapGesture{
//                                //apple Login
//                            }
                        
//                        //apple login
                        SignInWithAppleButton(isLoggedIn: $isLoggedIn)
                            .frame(width: 312, height: 44)
                            .cornerRadius(12)

                        Text("게스트로 로그인하기")
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(Color(0x191919))
                            .frame(width: 312, height: 44)
                            .background(Color(0xfdfdfd))
                            .cornerRadius(12)
                            .onTapGesture {
                                Global.shared.user = User(
                                    id: "005224c0-eec1-4638-9143-58cbfc9688c5",
                                    name: "테스트 계정",
                                    introduction: "For Test",
                                    postCount: 0,
                                    followerCount: 0,
                                    followingCount: 0,
                                    isFollowing: false
                                )
                                isLoggedIn = true
                            }
                    }
                    .padding(.top, 33)

                    Image("character-login")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 251.82 * 1.5, height: 69.09 * 1.5)
                        .padding(.top, 37)
                        .allowsHitTesting(false)
                }
            }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
