//
//  CalendarDateItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import SwiftUI

struct CalendarDateItem: View {
    @ObservedObject private var calendarVM: CalendarViewModel = .init()

    @Binding var selectionSet: Set<DateValue>

    let value: DateValue

    var body: some View {
        VStack {
            // TODO: 코드 다듬기
            if !value.isPrevDate {
                if calendarVM.scheduleList.first(where: { schedule in
                    CalendarHelper.isSameDay(date1: schedule.startTime, date2: value.date)
                }) != nil {
                    ZStack {
                        Circle()
                            .fill(.black)
                            .frame(width: 30, height: 30)
                            .opacity(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? 1 : 0)

                        Text("\(value.day)")
                            .font(.title3.bold())
                            .foregroundColor(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? .white : .primary)
                    }

                    // 일정 표시
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)

                    Spacer()
                } else {
                    ZStack {
                        Circle()
                            .fill(.black)
                            .frame(width: 30, height: 30)
                            .opacity(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? 1 : 0)

                        Text("\(value.day)")
                            .font(.title3.bold())
                            .foregroundColor(CalendarHelper.isSameDay(date1: value.date, date2: Date()) ? .white : .primary)
                    }
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

            // TODO: 할일 보여줄 수 있게 만들기
        }
    }
}

struct CalendarDateItem_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateItem(selectionSet: .constant([DateValue(day: 8, date: Date())]), value: DateValue(day: 7, date: Date()))
    }
}
