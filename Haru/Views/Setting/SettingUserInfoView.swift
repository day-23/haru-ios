//
//  SettingUserInfoView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/10.
//

import SwiftUI

struct SettingUserInfoView: View {
    @StateObject var userProfileVM: UserProfileViewModel

    var body: some View {
        HStack(spacing: 0) {
            ProfileImgView(imageUrl: userProfileVM.profileImageURL)
                .frame(width: 62, height: 62)
                .padding(.trailing, 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(userProfileVM.user.name)
                    .font(.pretendard(size: 20, weight: .bold))
                Text(userProfileVM.user.introduction)
                    .font(.pretendard(size: 14, weight: .regular))
            }
            .foregroundColor(Color(0x191919))

            Spacer()
        }
        .padding(.all, 20)
    }
}
