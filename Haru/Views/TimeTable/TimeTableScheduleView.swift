//
//  TimeTableScheduleView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import SwiftUI

struct TimeTableScheduleView: View {
    @StateObject var timeTableViewModel: TimeTableViewModel
    @State var calendarViewModel: CalendarViewModel = .init()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    private let column = [GridItem(.fixed(31)), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    private var range = (0 ..< 24 * 8)
    private var today: Date = .init()

    @State private var cellWidth: CGFloat? = nil
    private var cellHeight: CGFloat = 72
    private var minuteInterval: Double = 5.0
    private let borderWidth = 1
    private var fixed: Double = 31

    init(timeTableViewModel: StateObject<TimeTableViewModel>) {
        _timeTableViewModel = timeTableViewModel
    }

    var body: some View {
        Group {
            VStack {
                LazyVGrid(columns: column) {
                    Text("")

                    ForEach(week, id: \.self) { day in
                        Text(day)
                            .font(.pretendard(size: 14, weight: .medium))
                            .foregroundColor(
                                day == "일" ? Color(0xf71e58) : (day == "토" ? Color(0x1dafff) : Color(0x191919))
                            )
                    }
                }

                Divider()
                    .padding(.leading, 40)
                    .foregroundColor(Color(0xdbdbdb))

                LazyVGrid(columns: column) {
                    Text("")

                    ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                        if timeTableViewModel.thisWeek[index].month != timeTableViewModel.currentMonth {
                            Text(dayFormatter.string(from: timeTableViewModel.thisWeek[index]))
                                .font(.pretendard(size: 14, weight: .medium))
                                .foregroundColor(
                                    index == 0
                                        ? Color(0xfdbbcd)
                                        : (index == 6
                                            ? Color(0xbbe7ff)
                                            : Color(0xbababa))
                                )
                        } else {
                            Text(dayFormatter.string(from: timeTableViewModel.thisWeek[index]))
                                .font(.pretendard(size: 14, weight: .medium))
                                .foregroundColor(
                                    index == 0
                                        ? Color(0xf71e58)
                                        : (index == 6
                                            ? Color(0x1dafff)
                                            : Color(0x191919))
                                )
                        }
                    }
                }

                if !timeTableViewModel.scheduleListWithoutTime.isEmpty {
                    TimeTableScheduleTopView(timeTableViewModel: _timeTableViewModel)
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
                                    .font(.pretendard(size: 10, weight: .medium))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        } else {
                            Rectangle()
                                .foregroundColor(.white)
                                .border(Color(0xededed))
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
                                                    timeTableViewModel: _timeTableViewModel
                                                ))
                                        }
                                    }
                                }
                        }
                    }
                }
                .overlay(content: {
                    if cellWidth != nil {
                        ForEach($timeTableViewModel.scheduleList) { $schedule in
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
                                if schedule.id == "PREVIEW" {
                                    ScheduleItemView(schedule: $schedule)
                                        .opacity(0.5)
                                        .frame(width: frame.width, height: frame.height)
                                        .position(x: position.x, y: position.y)
                                } else {
                                    NavigationLink {
                                        ScheduleFormView(
                                            scheduleFormVM: ScheduleFormViewModel(
                                                schedule: schedule.data,
                                                categoryList: calendarViewModel.categoryList
                                            ) {
                                                timeTableViewModel.fetchScheduleList()
                                            },
                                            isSchModalVisible: .constant(false)
                                        )
                                    } label: {
                                        ScheduleItemView(schedule: $schedule)
                                    }
                                    .frame(width: frame.width, height: frame.height)
                                    .position(x: position.x, y: position.y)
                                    .onDrop(of: [.text], delegate: CellDropDelegate(
                                        dayIndex: schedule.data.repeatStart.indexOfWeek()!,
                                        hourIndex: schedule.data.repeatStart.hour,
                                        minuteIndex: schedule.data.repeatStart.minute / 5,
                                        timeTableViewModel: _timeTableViewModel
                                    ))
                                    .onDrag {
                                        let scheduleId = schedule.id
                                        timeTableViewModel.draggingSchedule = schedule
                                        return NSItemProvider(object: scheduleId as NSString)
                                    } preview: {
                                        ScheduleItemView(schedule: $schedule)
                                            .frame(width: 0.1, height: 0.1)
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}

private extension TimeTableScheduleView {
    func getScheduleIndex(schedule: Date) -> (row: Int, column: Int, minuteIndex: Int)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "H"

        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "m"

        let thisWeekString = Date.thisWeek().map { formatter.string(from: $0) }

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

        // 찾지 못했을 때
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
        x += CGFloat(fixed) + CGFloat(borderWidth * 8)
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
    @StateObject var timeTableViewModel: TimeTableViewModel

    init(
        dayIndex: Int,
        hourIndex: Int,
        minuteIndex: Int,
        timeTableViewModel: StateObject<TimeTableViewModel>
    ) {
        self.dayIndex = dayIndex
        self.hourIndex = hourIndex
        self.minuteIndex = minuteIndex
        _timeTableViewModel = timeTableViewModel
    }

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

    func dropExited(info: DropInfo) {
        timeTableViewModel.removePreview()
    }

    func dropEntered(info: DropInfo) {
        let year = CellDropDelegate.thisWeek[dayIndex].year
        let month = CellDropDelegate.thisWeek[dayIndex].month
        let day = CellDropDelegate.thisWeek[dayIndex].day
        let components = DateComponents(year: year, month: month, day: day, hour: hourIndex, minute: minuteIndex * 5)
        guard let date = Calendar.current.date(from: components) else {
            return
        }

        timeTableViewModel.insertPreview(date: date)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }

    func performDrop(info: DropInfo) -> Bool {
        if timeTableViewModel.draggingSchedule == nil {
            return false
        }

        let year = CellDropDelegate.thisWeek[dayIndex].year
        let month = CellDropDelegate.thisWeek[dayIndex].month
        let day = CellDropDelegate.thisWeek[dayIndex].day
        let components = DateComponents(year: year, month: month, day: day, hour: hourIndex, minute: minuteIndex * 5)
        guard let date = Calendar.current.date(from: components) else {
            return false
        }

        guard let draggingSchedule = timeTableViewModel.draggingSchedule else {
            return false
        }

        let diff = draggingSchedule.data.repeatEnd.diffToMinute(other:
            draggingSchedule.data.repeatStart
        )

        timeTableViewModel.removePreview()
        timeTableViewModel.updateDraggingSchedule(
            startDate: date,
            endDate: date.advanced(by: TimeInterval(60 * diff)),
            at: draggingSchedule.at
        )
        return true
    }
}
