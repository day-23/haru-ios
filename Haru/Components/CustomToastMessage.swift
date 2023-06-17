//
//  CustomToastMessage.swift
//  Haru
//
//  Created by 이준호 on 2023/06/17.
//

import SwiftUI

struct CustomToastMessage: View {
    var message: String

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    Color(0xfdfdfd)
                )

            HStack(spacing: 25) {
                Text("\(message)")
                    .font(.pretendard(size: 14, weight: .bold))
                    .foregroundColor(Color(0x1dafff))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
        }
        .fixedSize()
    }
}
