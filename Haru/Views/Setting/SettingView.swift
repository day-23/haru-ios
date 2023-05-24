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

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
                .padding(.leading, 20)

                Spacer()
            }
            .overlay {
                Text("설정")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }

            Divider()
                .padding(.top, 19)

            VStack(spacing: 14) {
                SettingRow(iconName: "account", content: "계정") {
                    // TODO: 계정으로 연결
                }

                SettingRow(iconName: "privacy", content: "개인정보 보호") {
                    // TODO: 개인정보 보호로 연결
                }

                SettingRow(iconName: "screen", content: "화면") {
                    // TODO: 화면으로 연결
                }

                SettingRow(iconName: "alarm", content: "알림") {
                    // TODO: 알림으로 연결
                }

                SettingRow(iconName: "information", content: "정보") {
                    // TODO: 정보로 연결
                }

                SettingRow(iconName: "invite-friend", content: "친구 초대") {
                    // TODO: 친구 초대로 연결
                }
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

                HStack(spacing: 0) {
                    Button {
                        KeychainService.logout()
                        isLoggedIn = false
                    } label: {
                        Text("로그아웃")
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))
                    }
                }.padding(.leading, 34)

                Divider()
            }
            .padding(.bottom, 64)
        }
        .navigationBarBackButtonHidden()
    }
}
