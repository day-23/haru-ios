//
//  CustomTabView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/27.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selection: Tab

    var body: some View {
        ZStack {
            Color(0xf1f1f5)
                .edgesIgnoringSafeArea(.all)

            HStack(spacing: 0) {
                Spacer()

                ForEach(Tab.allCases, id: \.self) { tab in
                    TabViewItem(
                        icon: tab.icon,
                        content: tab.title,
                        isSelected: selection == tab
                    )
                    .onTapGesture {
                        selection = tab
                    }

                    Spacer()
                }
            }
        }
        .frame(height: 56)
    }
}

private struct TabViewItem: View {
    var icon: String
    var content: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isSelected {
                Image(icon)
                    .resizable()
                    .frame(width: 28, height: 28)
            } else {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color(0xacacac))
            }

            Text(content)
                .font(.pretendard(size: 10, weight: .bold))
                .foregroundColor(
                    isSelected
                        ? Color(0x1dafff)
                        : Color(0xacacac)
                )
        }
    }
}
