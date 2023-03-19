//
//  TimeTableMainView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/20.
//

import SwiftUI

struct TimeTableCell {
    var scheduleList: [Date] = []
}

struct TimeTableMainView: View {
    // MARK: - View properties

    private let column = [GridItem(.fixed(20)), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    private let week = ["일", "월", "화", "수", "목", "금", "토"]
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M"
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()

    private var thisWeek: [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        ) else {
            return []
        }

        var datesOfWeek: [Date] = []
        for i in 0 ... 6 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            datesOfWeek.append(date)
        }
        return datesOfWeek
    }

    // MARK: - ViewModel properties

    @State private var range = (0 ..< 24 * 8)
    @State private var today: Date = .init()
    @State private var cellList: [TimeTableCell] = Array(repeating: TimeTableCell(), count: 24 * 7)

    // MARK: - Dummy Data

    private var scheduleList: [Date] = {
        let now = Date()
        let calendar = Calendar.current

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        var randomDates: [Date] = []

        for _ in 1 ... 10 { // change 10 to the number of dates you want to generate
            let randomTimeInterval = TimeInterval(arc4random_uniform(UInt32(endOfWeek.timeIntervalSince(startOfWeek)))) + startOfWeek.timeIntervalSinceReferenceDate

            let randomDate = Date(timeIntervalSinceReferenceDate: randomTimeInterval)

            randomDates.append(randomDate)
        }

        print(randomDates)
        return randomDates
    }()

    var body: some View {
        ZStack {
            VStack {
                // 날짜 레이아웃
                VStack {
                    HStack {
                        Text("\(monthFormatter.string(from: today))월")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.leading)
                        Spacer()
                    }

                    Group {
                        LazyVGrid(columns: [
                            GridItem(.fixed(20)), GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible())
                        ]) {
                            Text("")

                            ForEach(week, id: \.self) { day in
                                Text(day)
                            }
                        }

                        Divider()
                            .padding(.leading, 30)

                        LazyVGrid(columns: [
                            GridItem(.fixed(20)), GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible())
                        ]) {
                            Text("")

                            ForEach(thisWeek.indices, id: \.self) { index in
                                Text(dateFormatter.string(from: thisWeek[index]))
                            }
                        }
                    }
                }

                ScrollView {
                    LazyVGrid(
                        columns: column,
                        spacing: 0
                    ) {
                        ForEach(range.indices, id: \.self) { index in
                            if index % 8 == 0 {
                                VStack {
                                    Spacer()
                                    Text("\(index / 8 + 1)")
                                        .font(.system(size: 12))
                                }
                            } else {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .border(Color(0x000000, opacity: 0.1))
                                        .frame(height: 100)

                                    ForEach(cellList[index / 8 * 7 + index % 8 - 1].scheduleList, id: \.self) { schedule in
                                        Text(schedule.description)
                                    }
                                    .font(.system(size: 8))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.trailing)
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh"

            let thisWeekString = thisWeek.map { formatter.string(from: $0) }
            for schedule in scheduleList {
                let dateString = formatter.string(from: schedule)

                for index in thisWeekString.indices {
                    if thisWeekString[index] == dateString {
                        let hour = timeFormatter.string(from: schedule)
                        if let hour = Int(hour) {
                            cellList[hour * 7 + index].scheduleList.append(schedule)
                            cellList[(hour + 1) * 7 + index].scheduleList.append(schedule)
                        }
                    }
                }
            }
        }
    }
}

struct TimeTableMainView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableMainView()
    }
}
