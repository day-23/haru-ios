//
//  CalendarScheduleItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/09.
//

import SwiftUI

struct CalendarScheduleItem: View {
    @Binding var productivityList: [(Int, Event?)]
    var cellWidth: CGFloat
    var month: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(productivityList.indices, id: \.self) { index in
                Group {
                    if let productivity = productivityList[index].1 {
                        if let schedule = productivity as? Schedule {
                            Text("\(schedule.content)")
                                .font(.pretendard(size: 12, weight: .regular))
                                .padding(4)
                                .frame(width: cellWidth * CGFloat(productivityList[index].0) - 4, height: 16, alignment: .center)
                                .background(Color(schedule.category?.color))
                                .foregroundColor(Color(schedule.category?.color).fontColor)
                                .cornerRadius(4)
                                .opacity(month == schedule.repeatStart.month || month == schedule.repeatEnd.month ? 1 : 0.3)
                        } else if let todo = productivity as? Todo {
                            Text("\(todo.content)")
                                .font(.pretendard(size: 12, weight: .regular))
                                .padding(4)
                                .frame(width: cellWidth * CGFloat(productivityList[index].0) - 4, height: 16, alignment: .center)
                                .strikethrough(todo.completed, color: Color.gray2)
                                .foregroundColor(todo.completed ? Color.gray2 : Color.mainBlack)
                                .background(todo.completed ? Color.gray4 : Color.gradientEnd2)
                                .cornerRadius(4)
                                .opacity(month == (todo.endDate?.month ?? 0) ? 1 : 0.3)
                        }
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: cellWidth * CGFloat(productivityList[index].0) - 4, height: 16)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}
