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
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 7)

            Text("\(value.day)")
                .font(.pretendard(size: 12, weight: .medium))
                .foregroundColor(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? .gradientStart1 : Calendar.current.component(.weekday, from: value.date) == 1 ? .red : Calendar.current.component(.weekday, from: value.date) == 7 ? .gradientStart1 : .mainBlack)
                .background(
                    Circle()
                        .stroke(Color.gradation1, lineWidth: CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? 2 : 0)
                        .frame(width: 20, height: 20)
                )
            Spacer()
        } // VStack
        .frame(width: cellWidth, height: cellHeight, alignment: .top)
        .background(selectionSet.contains(value) ? .mint : .white)
        .opacity(!value.isNextDate && !value.isPrevDate && !selectionSet.contains(value) ? 1 : 0.3)
    }
}

// struct CalendarDateItem_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarDateItem(selectionSet: .constant([DateValue(day: 8, date: Date())]), value: DateValue(day: 7, date: Date()), cellHeight: 100, cellWidhth: UIScreen.main.bounds.width / 7)
//    }
// }
