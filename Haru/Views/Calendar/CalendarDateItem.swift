//
//  CalendarDateItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import SwiftUI

struct CalendarDateItem: View {
    var selectionSet: Set<DateValue>

    let value: DateValue
    let cellHeight: CGFloat
    let cellWidth: CGFloat

    var body: some View {
        let isSameDay = CalendarHelper.isSameDay(date1: value.date, date2: Date())
        return VStack(spacing: 0) {
            Spacer()
                .frame(height: 10)

            Text("\(value.day)")
                .frame(height: 20)
                .font(.pretendard(size: 14, weight: .regular))
                .foregroundColor(
                    isSameDay ?
                        .gradientStart1 :
                        Calendar.current.component(.weekday, from: value.date) == 1
                        ? .red : Calendar.current.component(.weekday, from: value.date) == 7 ? .gradientStart1 : Color(0x646464))
                .background(
                    Image("calendar-date-circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .opacity(isSameDay ? 1 : 0)
                )

            Spacer()
        } // VStack
        .frame(width: cellWidth, height: cellHeight, alignment: .top)
        .background(selectionSet.contains(value) ? .mint : .white)
        .opacity(!value.isNextDate && !value.isPrevDate && !selectionSet.contains(value) ? 1 : 0.3)
    }
}
