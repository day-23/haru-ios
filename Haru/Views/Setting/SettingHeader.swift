//
//  SettingHeader.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import SwiftUI

struct SettingHeader: View {
    var header: String
    var dismissAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button {
                dismissAction()
            } label: {
                Image("back-button")
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 20)

            Spacer()
        }
        .overlay {
            Text(header)
                .font(.pretendard(size: 20, weight: .bold))
                .foregroundColor(Color(0x191919))
        }
    }
}
