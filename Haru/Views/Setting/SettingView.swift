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
            Divider()
                .padding(.bottom, 19)
            Spacer()

            Button {
                KeychainService.logout()
                isLoggedIn = false
            } label: {
                Text("임시 로그아웃 (유저 정보 변경)")
                    .font(.pretendard(size: 14, weight: .bold))
                    .foregroundColor(Color(0xfdfdfd))
                    .frame(width: 312, height: 44)
                    .background(Color(0x191919))
                    .cornerRadius(12)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
            }

            ToolbarItem(placement: .navigation) {
                Text("설정")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }
        }
    }
}
