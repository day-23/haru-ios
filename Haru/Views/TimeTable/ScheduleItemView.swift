//
//  ScheduleItemView.swift
//  Haru
//
//  Created by 최정민 on 2023/04/05.
//

import SwiftUI

struct ScheduleItemView: View {
    @Binding var schedule: ScheduleCell

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color())

            Text(schedule.data.content)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.all, 4)
                .font(.pretendard(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
        .cornerRadius(10)
    }
}

extension ScheduleItemView {
    func color() -> Color {
        guard let color = schedule.data.category?.color,
              let hex = Int(color.suffix(6), radix: 16)
        else {
            return Color(0xEDEDED)
        }

        return Color(hex)
    }
}
