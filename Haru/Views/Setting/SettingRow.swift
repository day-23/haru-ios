//
//  SettingRow.swift
//  Haru
//
//  Created by 최정민 on 2023/05/25.
//

import SwiftUI

struct SettingRow<Destination: View>: View {
    let iconName: String
    let content: String
    @ViewBuilder var destination: () -> Destination // 헤더 오른쪽에 들어갈 아이템을 정의한다.

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

                    Image("back-button")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x646464))
                        .opacity(0.5)
                        .rotationEffect(Angle(degrees: 180))
                        .frame(width: 28, height: 28)
                }
            }

            Divider()
                .padding(.top, 8)
        }
    }
}
