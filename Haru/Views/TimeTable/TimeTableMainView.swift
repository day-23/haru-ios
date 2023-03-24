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
    private let tempFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, H:mm"
        return formatter
    }()

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

    @State private var cellWidth: CGFloat? = nil

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
                                    if index == 0 {
                                        Text("0")
                                    }
                                    Spacer()
                                    Text("\(index / 8 + 1)")
                                }
                                .font(.system(size: 12))
                            } else {
                                Rectangle()
                                    .foregroundColor(.white)
                                    .border(Color(0x000000, opacity: 0.1))
                                    .frame(height: 100)
                                    .background(
                                        GeometryReader(content: { proxy in
                                            Color.clear.onAppear {
                                                if cellWidth == nil {
                                                    cellWidth = proxy.size.width
                                                }
                                            }
                                        })
                                    )

                                // Index: index / 8 * 7 + index % 8 - 1
//                                Group {
//                                    let cellIndex = index / 8 * 7 + index % 8 - 1
//                                    ForEach(cellList[cellIndex].scheduleList, id: \.self) { schedule in
//                                        Text(schedule.description)
//                                    }
//                                }
//                                .font(.system(size: 8))
                            }
                        }
                    }
                    .overlay(content: {
                        if let cellWidth = cellWidth {
                            ForEach(scheduleList, id: \.self) { schedule in
                                if let scheduleIndex = getScheduleIndex(schedule: schedule) {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(Color(0x000000, opacity: 0.5))

                                        Text("\(tempFormatter.string(from: schedule))")
                                            .foregroundColor(.white)
                                            .font(.system(size: 8))
                                    }
                                    .frame(width: cellWidth, height: 100)
                                    .position(x: CGFloat(scheduleIndex.column) * cellWidth + 28 - (cellWidth * 0.5), y: CGFloat(scheduleIndex.row) * 100 - 50)
                                    .onAppear {
                                        print(tempFormatter.string(from: schedule), "\t", scheduleIndex)
                                        print(cellWidth)
                                    }
                                }
                            }
                        }
                    })
                }
            }
            .padding(.trailing)
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "H"

            let thisWeekString = thisWeek.map { formatter.string(from: $0) }
            for schedule in scheduleList {
                let dateString = formatter.string(from: schedule)

                for index in thisWeekString.indices {
                    if thisWeekString[index] == dateString {
                        let hour = timeFormatter.string(from: schedule)
                        if let hour = Int(hour) {
                            cellList[hour * 7 + index].scheduleList.append(schedule)
                            if hour + 1 < 24 {
                                cellList[(hour + 1) * 7 + index].scheduleList.append(schedule)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension TimeTableMainView {
    func getScheduleIndex(schedule: Date) -> (row: Int, column: Int)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H"

        let thisWeekString = thisWeek.map { formatter.string(from: $0) }

        let dateString = formatter.string(from: schedule)

        for index in thisWeekString.indices {
            if thisWeekString[index] == dateString {
                let hour = timeFormatter.string(from: schedule)
                print(hour)
                if let hour = Int(hour) {
                    return (hour + 1, index + 1)
                }
            }
        }

        // 찾지 못했을 때
        return nil
    }
}

struct TimeTableMainView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableMainView()
    }
}
