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

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "계정") {
                dismissAction.callAsFunction()
            }
            .padding(.bottom, 29)

            ZStack {
                LinearGradient(
                    colors: [Color(0xd2d7ff), Color(0xaad7ff), Color(0xd2d7ff)],
                    startPoint: .leading,
                    endPoint: .trailing
                ).opacity(0.5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("연동된 이메일")
                        .font(.pretendard(size: 12, weight: .regular))
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

                AccountRow(content: "하루 아이디", value: global.user?.haruId ?? "하루 아이디") {
                    // TODO: 하루 아이디 변경 View?
                }

                Spacer()
                Spacer()

                NavigationLink {
                    WithdrawalView()
                } label: {
                    VStack(spacing: 8) {
                        Text("계정 삭제하기")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0xf71e58))
                            .padding(.leading, 14)

                        Divider()
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}

struct AccountRow<Destination: View>: View {
    var content: String
    var value: String
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text(content)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 14)

                    Spacer()

                    Text(value)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.trailing, 10)

                    Image("detail-button")
                        .frame(width: 28, height: 28)
                }

                Divider()
            }
        }
    }
}
