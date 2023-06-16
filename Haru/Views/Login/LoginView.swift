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

                    Image("login-text-box")
                        .padding(.top, 51)
                        .padding(.leading, 128)
                        .overlay {
                            Text("1초만에 간편 로그인!")
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(Color(0x1dafff))
                                .offset(x: 65, y: 10)
                        }

                    VStack(spacing: 18) {
                        Button {
                            authViewModel.handleKakaoLogin { isLoggedIn in
                                self.isLoggedIn = isLoggedIn
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image("kakao-login-logo")
                                Text("카카오로 로그인하기")
                                    .font(.pretendard(size: 14, weight: .bold))
                                    .foregroundColor(Color(0x191919))
                            }
                            .frame(width: 312, height: 44)
                            .background(Color(0xfee500))
                            .cornerRadius(12)
                        }

                        SignInWithAppleButton(isLoggedIn: $isLoggedIn)
                            .frame(width: 312, height: 44)
                            .cornerRadius(12)

                        Text("하루 둘러보기")
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(Color(0x191919))
                            .frame(width: 312, height: 44)
                            .background(Color(0xfdfdfd))
                            .cornerRadius(12)
                            .onTapGesture {
                                withAnimation {
                                    Global.shared.showGuestMessage = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        Global.shared.showGuestMessage = false
                                    }
                                }

                                Global.shared.user = Me(
                                    user: User(
                                        id: "guest",
                                        name: "GUEST",
                                        introduction: "게스트 계정입니다.",
                                        postCount: 0,
                                        friendCount: 0,
                                        friendStatus: 0,
                                        isPublicAccount: true
                                    ),
                                    haruId: "GUEST",
                                    email: "Guest@haru.com",
                                    socialAccountType: "GUEST",
                                    isPostBrowsingEnabled: true,
                                    isAllowFeedLike: 2,
                                    isAllowFeedComment: 2,
                                    isAllowSearch: true,
                                    isMaliciousUser: false,
                                    morningAlarmTime: nil,
                                    nightAlarmTime: nil,
                                    isScheduleAlarmOn: true,
                                    createdAt: .now,
                                    accessToken: "GUEST"
                                )

                                isLoggedIn = true
                            }
                    }

                    Spacer()
                }
            }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
