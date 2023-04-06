//
//  TimeTableTodoRow.swift
//  Haru
//
//  Created by 최정민 on 2023/04/07.
//

import SwiftUI

struct TimeTableTodoRow: View {
    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    var index: Int
    var date: Date

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(week[index])
                    .font(.pretendard(size: 14, weight: .bold))
                    .foregroundColor(
                        index == 0 ? Color(0xF71E58) : index == 6 ? Color(0x1DAFFF) : Color(0x191919)
                    )
                    .padding(.bottom, 7)
                Text("\(date.day)")
                    .font(.pretendard(size: 14, weight: .bold))
                    .foregroundColor(
                        index == 0 ? Color(0xF71E58) : index == 6 ? Color(0x1DAFFF) : Color(0x191919)
                    )
            }
            .padding(.trailing, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TimeTableTodoItem()
                    TimeTableTodoItem()
                    TimeTableTodoItem()
                    TimeTableTodoItem()
                }
                .padding(1)
            }
        }
        .frame(width: 336, height: 74)
        .padding(.leading, 24)
        .padding(.trailing, 30)
    }
}
