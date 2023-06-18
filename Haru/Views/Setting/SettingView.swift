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
    @StateObject var userProfileVM: UserProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "설정") {
                self.dismissAction.callAsFunction()
            }

            Divider()
                .padding(.top, 19)

            VStack(spacing: 12) {
                SettingRow(iconName: "setting-account", content: "계정") {
                    AccountView(userProfileVM: userProfileVM)
                }

                SettingRow(iconName: "setting-privacy", content: "개인정보 보호") {
                    PrivacyView()
                }

//                SettingRow(iconName: "screen", content: "화면") {
//                    ScreenView()
//                }

                SettingRow(iconName: "setting-alarm", content: "알림") {
                    SettingAlarmView()
                }

                SettingRow(iconName: "setting-information", content: "정보") {
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
                Divider()
                    .padding(.horizontal, 20)

                Text("Version 1.0.0")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(Color(0x646464))
                    .padding(.leading, 34)

                Divider()
                    .padding(.horizontal, 20)

                if let user = Global.shared.user {
                    HStack(spacing: 0) {
                        Button {
                            self.isLogoutButtonClicked = true
                        } label: {
                            Text("로그아웃")
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(Color(0x646464))
                        }
                        .confirmationDialog(
                            "\(user.user.name) 계정에서 로그아웃 할까요?",
                            isPresented: self.$isLogoutButtonClicked,
                            titleVisibility: .visible
                        ) {
                            Button("로그아웃", role: .destructive) {
                                Global.shared.user = nil
                                KeychainService.logout()
                                AlarmHelper.removeAllNotification()
                                self.isLoggedIn = false
                            }
                        }

                    }.padding(.leading, 34)
                }
            }
            .padding(.bottom, 64)
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: Private

    @State private var isLogoutButtonClicked: Bool = false
}

struct SettingRow<Destination: View>: View {
    let iconName: String
    let content: String
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink {
                self.destination()
            } label: {
                HStack(spacing: 0) {
                    Image(self.iconName)
                        .renderingMode(.template)
                        .foregroundColor(Color(0x646464))
                        .frame(width: 28, height: 28)
                        .padding(.trailing, 10)

                    Text(self.content)
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x191919))

                    Spacer()

                    Image("setting-detail-button")
                        .frame(width: 28, height: 28)
                }
            }

            Divider()
                .padding(.top, 8)
        }
    }
}
