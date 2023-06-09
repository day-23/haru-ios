//
//  AccountView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var global: Global
    @StateObject var userProfileVM: UserProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "계정") {
                dismissAction.callAsFunction()
            }

            Divider()
                .padding(.top, 19)

            SettingUserInfoView(userProfileVM: userProfileVM)

            ZStack {
                Color(0xf1f1f5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("연동된 이메일")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x191919))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(global.user?.email ?? "unknown@haru.com")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 29)
            }
            .frame(height: 76)
            .padding(.bottom, 54)

            VStack(spacing: 14) {
                AccountRow(content: "프로필", value: global.user?.user.name ?? "이름 없음") {
                    // TODO: 프로필 View
                }

                AccountRow(content: "하루 아이디", value: global.user?.haruId ?? "하루 아이디", isLink: false) {
                    // TODO: 하루 아이디 변경 View?
                }
            }
            .padding(.horizontal, 20)

            Spacer()
            Spacer()

            NavigationLink {
                WithdrawalView(userProfileVM: userProfileVM)
            } label: {
                VStack(spacing: 14) {
                    Divider()

                    Text("계정 삭제하기")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0xf71e58))
                        .padding(.leading, 34)
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}

struct AccountRow<Destination: View>: View {
    var content: String
    var value: String
    var isLink: Bool = true
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        if isLink {
            NavigationLink {
                destination()
            } label: {
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Text(content)
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x191919))
                            .padding(.leading, 14)

                        Spacer()

                        Text(value)
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))
                            .padding(.trailing, 10)

                        Image("setting-detail-button")
                            .frame(width: 28, height: 28)
                    }

                    Divider()
                }
            }
        } else {
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text(content)
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 14)

                    Spacer()

                    Text(value)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.trailing, 10)

                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 28, height: 28)
                }

                Divider()
            }
        }
    }
}
