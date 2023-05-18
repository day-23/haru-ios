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
                .font(.pretendard(size: 10, weight: .medium))
                .foregroundColor(.black)
                .padding(.vertical, 2)
                .padding(.horizontal, 3)
        }
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
