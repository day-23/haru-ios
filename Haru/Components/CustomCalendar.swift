//
//  CustomCalendar.swift
//  Haru
//
//  Created by 이준호 on 2023/06/12.
//

import SwiftUI

struct CustomCalendar: View {
    @Binding var bindingDate: Date
    @State var curDate: Date = .init()

    var numberOfWeekInMonth: Int {
        CalendarHelper.numberOfWeeksInMonth(date: curDate)
    }

    var dateList: [DateValue] {
        CalendarHelper.extractDate(0, true, curDate: curDate)
    }

    @State var toggle: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(CalendarHelper.extraDate(date: curDate)[0])년 \(CalendarHelper.extraDate(date: curDate)[1])월")
                    .font(.pretendard(size: 24, weight: .bold))
                    .padding(.trailing, 4)

                Button {
                    withAnimation {
                        toggle.toggle()
                    }
                } label: {
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: toggle ? 90 : 0))
                }

                Spacer()

                Button {
                    withAnimation {
                        curDate = CalendarHelper.subOneMonth(date: curDate)
                    }
                } label: {
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: 180))
                }
                .padding(.trailing, 10)

                Button {
                    withAnimation {
                        curDate = CalendarHelper.addOneMonth(date: curDate)
                    }
                } label: {
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                }
            }
            .foregroundColor(Color(0xFDFDFD))
            .padding(.horizontal, 24)
            .padding(.top, 25)
            .padding(.bottom, 15)
            .background(
                RadialGradient(
                    colors: [
                        Color(0xAAD7FF),
                        Color(0xD2D7FF)
                    ],
                    center: .bottom,
                    startRadius: 0,
                    endRadius: 290
                )
            )
            .cornerRadius(10, corners: [.topLeft, .topRight])

            if !toggle {
                Group {
                    let dateColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                    LazyVGrid(columns: dateColumns, spacing: 0) {
                        ForEach(0 ..< 7, id: \.self) { day in
                            Text("\(CalendarHelper.getDays(true)[day])")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0xACACAC))
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 18)

                    LazyVGrid(columns: dateColumns, spacing: 16) {
                        ForEach(0 ..< numberOfWeekInMonth, id: \.self) { week in
                            ForEach(0 ..< 7) { day in
                                let dateValue = dateList[week * 7 + day]
                                if !dateValue.isNextDate, !dateValue.isPrevDate {
                                    Button {
                                        curDate = dateValue.date
                                    } label: {
                                        Text("\(dateValue.day)")
                                            .font(.pretendard(size: 16, weight: .regular))
                                            .foregroundColor(
                                                curDate.day == dateValue.day ? Color(0x1DAFFF) : Color(0xACACAC)
                                            )
                                    }
                                } else {
                                    Text("\(dateValue.day)")
                                        .font(.pretendard(size: 16, weight: .regular))
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    .animation(.none)
                }
                .padding(.horizontal, 25)
            } else {
                HStack(spacing: 6) {
                    Picker("year", selection: $curDate) {
                        ForEach(yearDates(), id: \.self) { date in
                            Text("\(date.year)")
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("month", selection: $curDate) {
                        ForEach(monthDates(), id: \.self) { date in
                            Text("\(date.month)")
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            Spacer()
        }
        .frame(minWidth: 300, maxWidth: 300, minHeight: 360, maxHeight: 360)
        .background(Color(0xFDFDFD))
        .cornerRadius(10)
        .shadow(radius: 20)

        .onAppear {
            curDate = bindingDate
        }
        .onChange(of: curDate) { _ in
            bindingDate = curDate
        }
    }

    func yearDates() -> [Date] {
        var result: [Date] = []
        var date = CalendarHelper.stringToDate(dateString: "\(1980)-\(curDate.month)-\(curDate.day)")!
        for _ in 0 ... 200 {
            result.append(date)
            date = CalendarHelper.addOneYear(date: date)
        }
        return result
    }

    func monthDates() -> [Date] {
        var result: [Date] = []
        var date = CalendarHelper.stringToDate(dateString: "\(curDate.year)-01-01")!
        for _ in 0 ... 11 {
            result.append(date)
            date = CalendarHelper.addOneMonth(date: date)
        }
        return result
    }
}

struct CustomCalendar_Previews: PreviewProvider {
    static var previews: some View {
        CustomCalendar(bindingDate: .constant(CalendarHelper.stringToDate(dateString: "2021-1-31")!))
    }
}
