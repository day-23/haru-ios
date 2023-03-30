//
//  TimeTableMainView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct TimeTableMainView: View {
    //  MARK: - Properties

    @StateObject var timeTableViewModel: TimeTableViewModel

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

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private var range = (0 ..< 24 * 8)
    private var today: Date = .init()

    @State private var cellWidth: CGFloat? = nil
    private var cellHeight: CGFloat = 168
    private var minuteInterval: Double = 5.0
    private let showHourTextWidth = 20
    private let borderWidth = 1

    init(timeTableViewModel: StateObject<TimeTableViewModel>) {
        _timeTableViewModel = timeTableViewModel
    }

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

                            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                                Text(dayFormatter.string(from: timeTableViewModel.thisWeek[index]))
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
                                                    .foregroundColor(Color(0xffffff, opacity: 0.001))
                                                    .onDrop(of: [.text], delegate: CellDropDelegate(
                                                        dayIndex: index % 8 - 1,
                                                        hourIndex: index / 8,
                                                        minuteIndex: minuteIndex,
                                                        dragging: $timeTableViewModel.draggingSchedule
                                                    ) { date in
                                                        guard let draggingSchedule = timeTableViewModel.draggingSchedule else {
                                                            return
                                                        }

                                                        let diff = draggingSchedule.data.repeatEnd.diffToMinute(other:
                                                            draggingSchedule.data.repeatStart
                                                        )
                                                        timeTableViewModel.updateDraggingSchedule(date, date.advanced(by: TimeInterval(60 * diff)))
                                                    })
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .overlay(content: {
                        if cellWidth != nil {
                            ForEach(timeTableViewModel.scheduleList) { schedule in
                                if let scheduleIndex = getScheduleIndex(schedule: schedule.data.repeatStart),
                                   let frame = calcFrame(
                                       weight: schedule.weight,
                                       duration: schedule.data.repeatEnd.diffToMinute(other: schedule.data.repeatStart)
                                   ),
                                   let position = calcPosition(
                                       row: scheduleIndex.row,
                                       column: scheduleIndex.column,
                                       minuteIndex: scheduleIndex.minuteIndex,
                                       weight: schedule.weight,
                                       order: schedule.order,
                                       frame: frame
                                   )
                                {
                                    ScheduleItemView(schedule: schedule)
                                        .frame(width: frame.width, height: frame.height)
                                        .position(x: position.x, y: position.y)
                                        .onDrag {
                                            timeTableViewModel.draggingSchedule = schedule
                                            return NSItemProvider(object: schedule.id as NSString)
                                        } preview: {
                                            ScheduleItemView(schedule: schedule)
                                                .frame(width: frame.width, height: frame.height)
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
            timeTableViewModel.fetchScheduleList()
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

        let thisWeekString = timeTableViewModel.thisWeek.map { formatter.string(from: $0) }

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

    func calcPosition(
        row: Int,
        column: Int,
        minuteIndex: Int,
        weight: Int,
        order: Int,
        frame: (width: CGFloat, height: CGFloat)
    ) -> (x: CGFloat, y: CGFloat)? {
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
        y += frame.height * 0.5 - cellHeight

        return (x: x, y: y)
    }

    func calcFrame(
        weight: Int,
        duration: Int = 60
    ) -> (width: CGFloat, height: CGFloat)? {
        guard let cellWidth = cellWidth else {
            return nil
        }

        let width: CGFloat = cellWidth * CGFloat(1.0 / Double(weight))
        let height: CGFloat = cellHeight * CGFloat(Double(duration) / 60.0)

        return (width: width, height: height)
    }
}

struct CellDropDelegate: DropDelegate {
    var dayIndex: Int
    var hourIndex: Int
    var minuteIndex: Int
    @Binding var dragging: ScheduleCell?
    var completion: (Date) -> Void

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

    func dropEntered(info: DropInfo) {}

    func dropExited(info: DropInfo) {}

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let dragging = dragging else {
            return false
        }
        let calendar = Calendar.current
        let year = calendar.component(.year, from: dragging.data.repeatStart)
        let month = calendar.component(.month, from: dragging.data.repeatStart)
        let day = calendar.component(.day, from: CellDropDelegate.thisWeek[dayIndex])
        let components = DateComponents(year: year, month: month, day: day, hour: hourIndex, minute: minuteIndex * 5)
        guard let date = Calendar.current.date(from: components) else {
            return false
        }
        completion(date)
        return true
    }
}

struct ScheduleItemView: View {
    @State var schedule: ScheduleCell

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, H:mm"
        return formatter
    }()

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(0x000000, opacity: 0.5))

            Text("\(formatter.string(from: schedule.data.repeatStart))")
                .foregroundColor(.white)
                .font(.system(size: 8))
        }
        .cornerRadius(10)
    }
}
