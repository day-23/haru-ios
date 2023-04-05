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
    //  FIXME: - 민재형한테 리스폰스로 카테고리 들어오게 만들어달라고 부탁하기
    func color() -> Color {
        guard let color = schedule.data.category?.color,
              let hex = Int(color.suffix(6), radix: 16)
        else {
            return Color(0xEDEDED)
        }

        return Color(hex)
    }
}
