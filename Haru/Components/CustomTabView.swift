//
//  CustomTabView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/27.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selection: Int

    var body: some View {
        ZStack {
            Color(0xf1f1f5)
                .edgesIgnoringSafeArea(.all)

            HStack(spacing: 0) {
                TabViewItem(
                    icon: selection != 0
                        ? "sns"
                        : "sns-gradient",
                    content: "SNS",
                    isSelected: selection == 0
                )

                Spacer()

                TabViewItem(
                    icon: selection != 1
                        ? "todo"
                        : "todo-gradient",
                    content: "TODO",
                    isSelected: selection == 1
                )

                Spacer()

                TabViewItem(
                    icon: selection != 2
                        ? "calendar-tabview"
                        : "calendar-gradient",
                    content: "CAL",
                    isSelected: selection == 2
                )

                Spacer()

                TabViewItem(
                    icon: selection != 3
                        ? "timetable"
                        : "timetable-gradient",
                    content: "T.T",
                    isSelected: selection == 3
                )

                Spacer()

                TabViewItem(
                    icon: selection != 4
                        ? "my"
                        : "my-gradient",
                    content: "MY",
                    isSelected: selection == 4
                )
            }
            .padding(.horizontal, 36)
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

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView(selection: .constant(0))
    }
}
