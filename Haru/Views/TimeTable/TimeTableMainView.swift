//
//  TimeTableMainView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct DateCell: Identifiable {
    var id: String
    var date: Date
    var weight: Int
    var order: Int
}

struct DateList: Identifiable {
    var id: String
    var dateList: [DateCell]
}

struct TimeTableMainView: View {
    //  MARK: - View properties

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

    private let showHourTextWidth = 20
    private let borderWidth = 1

    @State private var cellWidth: CGFloat? = nil
    private var cellHeight: CGFloat = 120
    private var minuteInterval: Double = 5.0

    @State var dragging: DateCell? = nil

    //  MARK: - ViewModel properties

    @State private var range = (0 ..< 24 * 8)
    @State private var today: Date = .init()
    @State private var scheduleList: [DateList] = []

    //  MARK: - Dummy Data

    private var dummyScheduleList: [Date] = {
        let now = Date()
        let calendar = Calendar.current

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        var randomDates: [Date] = []

        for _ in 1 ... 75 { //  change 10 to the number of dates you want to generate
            let randomTimeInterval = TimeInterval(arc4random_uniform(UInt32(endOfWeek.timeIntervalSince(startOfWeek)))) + startOfWeek.timeIntervalSinceReferenceDate

            let randomDate = Date(timeIntervalSinceReferenceDate: randomTimeInterval)

            randomDates.append(randomDate)
        }

        return randomDates
    }()

    var body: some View {
        ZStack {
            VStack {
                //  날짜 레이아웃
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
                                    .frame(height: cellHeight)
                                    .background(
                                        GeometryReader(content: { proxy in
                                            Color.clear.onAppear {
                                                if cellWidth == nil {
                                                    cellWidth = proxy.size.width
                                                }
                                            }
                                        })
                                    )
                                    .overlay {
                                        VStack(spacing: 0) {
                                            ForEach(0 ..< (60 / Int(minuteInterval)), id: \.self) {
                                                minuteIndex in
                                                Rectangle()
                                                    .foregroundColor(.white)
                                                    .border(Color(0x000000, opacity: 0.1))
                                                    .onDrop(of: [.text], delegate: CellDropDelegate(
                                                        dayIndex: index % 8 - 1,
                                                        hourIndex: index / 8,
                                                        minuteIndex: minuteIndex,
                                                        dragging: $dragging
                                                    ) {
                                                        dragging = nil
                                                        findUnion()
                                                    })
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .overlay(content: {
                        if cellWidth != nil {
                            ForEach(scheduleList) { dateList in
                                ForEach(dateList.dateList) { schedule in
                                    if let scheduleIndex = getScheduleIndex(schedule: schedule.date),
                                       let position = calcPosition(row: scheduleIndex.row, column: scheduleIndex.column,
                                                                   minuteIndex: scheduleIndex.minuteIndex, weight: schedule.weight,
                                                                   order: schedule.order),
                                       let frame = calcFrame(weight: schedule.weight)
                                    {
                                        ScheduleItemView(schedule: schedule)
                                            .frame(width: frame.width, height: frame.height)
                                            .position(x: position.x, y: position.y)
                                            .onDrag {
                                                dragging = schedule
                                                return NSItemProvider(object: schedule.id as NSString)
                                            } preview: {
                                                ScheduleItemView(schedule: schedule)
                                                    .frame(width: frame.width, height: frame.height)
                                            }
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
            findUnion()
        }
    }
}

private extension TimeTableMainView {
    func getScheduleIndex(schedule: Date) -> (row: Int, column: Int, minuteIndex: Int)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "H"

        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "m"

        let thisWeekString = thisWeek.map { formatter.string(from: $0) }

        let dateString = formatter.string(from: schedule)

        for index in thisWeekString.indices {
            if thisWeekString[index] == dateString {
                let hour = hourFormatter.string(from: schedule)
                if let hour = Int(hour) {
                    let minute = minuteFormatter.string(from: schedule)
                    if let minute = Int(minute) {
                        return (hour + 1, index + 1, minute / 5)
                    }
                }
            }
        }

        //  찾지 못했을 때
        return nil
    }

    func calcPosition(row: Int, column: Int, minuteIndex: Int, weight: Int, order: Int) -> (x: CGFloat, y: CGFloat)? {
        guard let cellWidth = cellWidth else {
            return nil
        }

        let width = cellWidth * CGFloat(1.0 / Double(weight))

        var x = CGFloat(column) * cellWidth
        x += CGFloat(showHourTextWidth) + CGFloat(borderWidth * 8)
        x -= width == cellWidth ?
            width * 0.5 :
            width * Double(weight) - width * 0.5

        for _ in 1 ..< order {
            x += width
        }

        var y = CGFloat(row) * cellHeight
        y += cellHeight * CGFloat(Double(minuteIndex) * minuteInterval / 60.0)
        y -= cellHeight * 0.5

        return (x: x, y: y)
    }

    func calcFrame(weight: Int, duration: Int = 60) -> (width: CGFloat, height: CGFloat)? {
        guard let cellWidth = cellWidth else {
            return nil
        }

        let width: CGFloat = cellWidth * CGFloat(1.0 / Double(weight))
        let height: CGFloat = cellHeight * CGFloat(Double(duration) / minuteInterval * minuteInterval / 60.0)

        return (width: width, height: height)
    }

    private func findUnion() {
        scheduleList = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let thisWeekString = thisWeek.map { formatter.string(from: $0) }

        for weekString in thisWeekString {
            scheduleList.append(DateList(id: weekString, dateList: []))
        }

        for schedule in dummyScheduleList {
            if let scheduleIndex = getScheduleIndex(schedule: schedule) {
                scheduleList[scheduleIndex.column - 1].dateList.append(
                    DateCell(id: UUID().uuidString, date: schedule, weight: 1, order: 1)
                )
            }
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmmss"

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"

        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "mm"

        for i in scheduleList.indices {
            scheduleList[i].dateList.sort { first, second in
                timeFormatter.string(from: first.date) < timeFormatter.string(from: second.date)
            }

            var parent: [Int] = []
            for index in scheduleList[i].dateList.indices { parent.append(index) }

            for j in scheduleList[i].dateList.indices {
                for k in j + 1 ..< scheduleList[i].dateList.count {
                    let date1 = scheduleList[i].dateList[j].date.addingTimeInterval(TimeInterval(60 * 60))
                    let date2 = scheduleList[i].dateList[k].date

                    let date1Hour = hourFormatter.string(from: date1)
                    let date2Hour = hourFormatter.string(from: date2)

                    if date1Hour < date2Hour {
                        break
                    }

                    if date1Hour == date2Hour {
                        let date1Minute = minuteFormatter.string(from: date1)
                        let date2Minute = minuteFormatter.string(from: date2)

                        if date1Minute <= date2Minute {
                            break
                        }
                    }

                    unionMerge(parent: &parent, x: j, y: k)
                }
            }

            var set: [[Int]] = Array(repeating: [], count: scheduleList[i].dateList.count)
            for j in scheduleList[i].dateList.indices {
                parent[j] = unionFind(parent: &parent, x: j)
                set[parent[j]].append(j)
            }

            for j in set.indices {
                for (order, index) in zip(set[j].indices, set[j]) {
                    scheduleList[i].dateList[index].weight = set[j].count
                    scheduleList[i].dateList[index].order = order + 1
                }
            }
        }
    }

    private func unionFind(parent: inout [Int], x: Int) -> Int {
        if parent[x] == x {
            return x
        }
        let alt = unionFind(parent: &parent, x: parent[x])
        parent[x] = alt
        return alt
    }

    private func unionMerge(parent: inout [Int], x: Int, y: Int) {
        let parentX = unionFind(parent: &parent, x: x)
        let parentY = unionFind(parent: &parent, x: y)

        if parentX == parentY {
            return
        }

        if parentX < parentY {
            parent[x] = y
        } else {
            parent[y] = x
        }
    }
}

//  !!!: - 각 셀에 이벤트를 걸자 (시간 값)

struct CellDropDelegate: DropDelegate {
    var dayIndex: Int
    var hourIndex: Int
    var minuteIndex: Int
    @Binding var dragging: DateCell?
    var completion: () -> Void

    private static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()

    private static var thisWeek: [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
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

    // Drop entered called
    func dropEntered(info: DropInfo) {}

    // Drop exited called
    func dropExited(info: DropInfo) {}

    // Drop has been updated
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }

    // This function is executed when the user "drops" their object
    func performDrop(info: DropInfo) -> Bool {
        guard let dragging = dragging else {
            return false
        }

        let calendar = Calendar.current
        let year = calendar.component(.year, from: dragging.date)
        let month = calendar.component(.month, from: dragging.date)
        let day = calendar.component(.day, from: CellDropDelegate.thisWeek[dayIndex])
        let components = DateComponents(year: year, month: month, day: day, hour: hourIndex, minute: minuteIndex * 5)
        guard let date = Calendar.current.date(from: components) else {
            return false
        }
        self.dragging?.date = date
        completion()
        return true
    }
}

struct ScheduleItemView: View {
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, H:mm"
        return formatter
    }()

    @State var schedule: DateCell

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(0x000000, opacity: 0.5))

            Text("\(formatter.string(from: schedule.date))")
                .foregroundColor(.white)
                .font(.system(size: 8))
        }
        .cornerRadius(10)
    }
}
