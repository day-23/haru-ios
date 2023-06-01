//
//  SettingView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismissAction
    @Binding var isLoggedIn: Bool
    @State private var isLogoutButtonClicked: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "설정") {
                dismissAction.callAsFunction()
            }

            Divider()
                .padding(.top, 19)

            VStack(spacing: 14) {
                SettingRow(iconName: "account", content: "계정") {
                    AccountView()
                }

                SettingRow(iconName: "privacy", content: "개인정보 보호") {
                    PrivacyView()
                }

//                SettingRow(iconName: "screen", content: "화면") {
//                    ScreenView()
//                }

                SettingRow(iconName: "alarm-setting", content: "알림") {
                    // TODO: 알림으로 연결
                }

                SettingRow(iconName: "information", content: "정보") {
                    InformationView()
                }

//                SettingRow(iconName: "invite-friend", content: "친구 초대") {
//                    // TODO: 친구 초대로 연결
//                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            Spacer()

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    NavigationLink {} label: {
                        Text("Version")
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))
                    }
                }.padding(.leading, 34)

                Divider()

                if let user = Global.shared.user {
                    HStack(spacing: 0) {
                        Button {
                            isLogoutButtonClicked = true
                        } label: {
                            Text("로그아웃")
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(Color(0x646464))
                        }
                        .confirmationDialog(
                            "\(user.user.name) 계정에서 로그아웃 할까요?",
                            isPresented: $isLogoutButtonClicked,
                            titleVisibility: .visible
                        ) {
                            Button("로그아웃", role: .destructive) {
                                KeychainService.logout()
                                AlarmHelper.removeAllNotification()
                                isLoggedIn = false
                            }
                        }

                    }.padding(.leading, 34)

                    Divider()
                }
            }
            .padding(.bottom, 64)
        }
        .navigationBarBackButtonHidden()
    }
}

struct SettingRow<Destination: View>: View {
    let iconName: String
    let content: String
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink {
                destination()
            } label: {
                HStack(spacing: 0) {
                    Image(iconName)
                        .renderingMode(.template)
                        .foregroundColor(Color(0x646464))
                        .frame(width: 28, height: 28)
                        .padding(.trailing, 10)

                    Text(content)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x191919))

                    Spacer()

                    Image("detail-button")
                        .frame(width: 28, height: 28)
                }
            }

            Divider()
                .padding(.top, 8)
        }
    }
}
