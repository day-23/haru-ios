//
//  CalendarDateItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import SwiftUI

struct CalendarDateItem: View {
    @Binding var selectionSet: Set<DateValue>

    let value: DateValue
    var cellHeight: CGFloat
    var cellWidhth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 2)

            ZStack {
                Group {
                    if CalendarHelper.isSameDay(date1: value.date, date2: Date()) {
                        Circle()
                            .strokeBorder(.gradation1, lineWidth: 2)
                            .frame(width: 24, height: 24)
                    } else {
                        Circle()
                            .fill(.clear)
                            .frame(width: 24, height: 24)
                    }

                    Text("\(value.day)")
                        .font(Font.custom(Constants.Regular, size: 14))
                        .foregroundColor(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? .blue : .primary)
                }
                .opacity(!value.isNextDate && !value.isPrevDate ? 1 : 0.5)
            }

            Spacer()
                .frame(height: 1)
        } // VStack
        .frame(width: cellWidhth, height: cellHeight, alignment: .top)
        .background(selectionSet.contains(value) ? .cyan : .white)
    }
}

struct CalendarDateItem_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateItem(selectionSet: .constant([DateValue(day: 8, date: Date())]), value: DateValue(day: 7, date: Date()), cellHeight: 100, cellWidhth: UIScreen.main.bounds.width / 7)
    }
}