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

    var body: some View {
        VStack(spacing: 0) {
            // TODO: 코드 다듬기
            Spacer()
                .frame(height: 1)

            if !value.isPrevDate, !value.isNextDate {
                ZStack {
                    Circle()
                        .fill(.black)
                        .frame(width: 30, height: 30)
                        .opacity(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? 1 : 0)

                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? .white : .primary)
                }

            } else {
                ZStack {
                    Circle()
                        .fill(.black)
                        .frame(width: 30, height: 30)
                        .opacity(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? 1 : 0)

                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(Color.gray)
                }
            }

            Spacer()
                .frame(height: 1)
        } // VStack
    }
}

struct CalendarDateItem_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateItem(selectionSet: .constant([DateValue(day: 8, date: Date())]), value: DateValue(day: 7, date: Date()))
    }
}
