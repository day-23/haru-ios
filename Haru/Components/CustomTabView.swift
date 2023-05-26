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
                        icon: selection == tab
                            ? tab.selectedIcon
                            : tab.icon,
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
            Image(icon)
                .resizable()
                .frame(width: 26, height: 26)

            Text(content)
                .font(.pretendard(size: 10, weight: .bold))
                .foregroundColor(
                    isSelected
                        ? Color(0x1dafff)
                        : Color(0x646464)
                )
        }
    }
}
