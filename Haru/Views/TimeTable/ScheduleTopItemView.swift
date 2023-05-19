//
//  ScheduleTopItemView.swift
//  Haru
//
//  Created by 최정민 on 2023/04/05.
//

import SwiftUI

struct ScheduleTopItemView: View {
    @Binding var schedule: ScheduleCell
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ZStack {
            color()

            Text(schedule.data.content)
                .font(.pretendard(size: 12, weight: .regular))
                .foregroundColor(color().fontColor)
                .padding(.all, 2)
        }
        .frame(width: width, height: height)
        .cornerRadius(4)
    }
}

extension ScheduleTopItemView {
    func color() -> Color {
        guard let color = schedule.data.category?.color,
              let hex = Int(color.suffix(6), radix: 16)
        else {
            return Color(0xEDEDED)
        }

        return Color(hex)
    }
}
