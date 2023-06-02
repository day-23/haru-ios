//
//  TimeTableScheduleView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import SwiftUI
import SwiftUIPager

struct TimeTableScheduleView: View {
    @StateObject var timeTableViewModel: TimeTableViewModel
    @StateObject var calendarViewModel: CalendarViewModel

    @Binding var isPopupVisible: Bool

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    private var fixed: Double = 20
    private let column = [GridItem(.fixed(20)), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    private var range = (0 ..< 24 * 8)
    private var today: Date = .init()

    @State private var cellWidth: CGFloat? = nil
    private var cellHeight: CGFloat = 72
    private var minuteInterval: Double = 5.0
    private let borderWidth = 1

    @State private var topViewHeight: CGFloat? = nil

    @StateObject var page: Page = .withIndex(1)

    init(
        timeTableViewModel: StateObject<TimeTableViewModel>,
        calendarViewModel: StateObject<CalendarViewModel>,
        isPopupVisible: Binding<Bool>
    ) {
        _timeTableViewModel = timeTableViewModel
        _calendarViewModel = calendarViewModel
        _isPopupVisible = isPopupVisible
    }

    var body: some View {
        Group {
            // 날짜 및 하루종일, 여러 날짜에 걸쳐 나타나는 일정이 보이는 View
            Pager(page: page,
                  data: timeTableViewModel.indices,
                  id: \.self) { _ in
                VStack(spacing: 0) {
                    LazyVGrid(columns: column, spacing: 30) {
                        Text("")

                        ForEach(week.indices, id: \.self) { index in
                            Text(week[index])
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(
                                    index == 0
                                        ? Color(0xf71e58)
                                        : (index == 6
                                            ? Color(0x1dafff)
                                            : Color(0x646464)
                                        )
                                )
                                .padding(.bottom, 3)
                                .onTapGesture {
                                    calendarViewModel.pivotDate = timeTableViewModel.thisWeek[index]
                                    calendarViewModel.getSelectedScheduleList()
                                    isPopupVisible = true
                                }
                        }
                    }

                    Rectangle()
                        .frame(height: 1)
                        .padding(.leading, 28)
                        .foregroundColor(Color(0xdbdbdb))

                    LazyVGrid(columns: column, spacing: 30) {
                        Text("")

                        ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                            Text(dayFormatter.string(from: timeTableViewModel.thisWeek[index]))
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(
                                    timeTableViewModel.thisWeek[index].month != timeTableViewModel.currentMonth
                                        ? (index == 0
                                            ? Color(0xfdbbcd)
                                            : (index == 6
                                                ? Color(0xbbe7ff)
                                                : Color(0xebebeb)
                                            )
                                        )
                                        : (index == 0
                                            ? Color(0xf71e58)
                                            : (index == 6
                                                ? Color(0x1dafff)
                                                : Color(0x646464)
                                            )
                                        )
                                )
                                .padding(.top, 6)
                                .onTapGesture {
                                    calendarViewModel.pivotDate = timeTableViewModel.thisWeek[index]
                                    calendarViewModel.getSelectedScheduleList()
                                    isPopupVisible = true
                                }
                        }
                    }

                    if timeTableViewModel.scheduleListWithoutTime.first(where: { !$0.isEmpty }) != nil {
                        TimeTableScheduleTopView(
                            timeTableViewModel: _timeTableViewModel,
                            calendarViewModel: _calendarViewModel,
                            isPopupVisible: _isPopupVisible
                        )
                        .padding(.top, 2)
                    }
                }
                .overlay {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                topViewHeight = proxy.size.height
                            }
                            .onChange(of: timeTableViewModel.maxRowCount) { _ in
                                topViewHeight = proxy.size.height
                            }
                    }
                }
            }.onPageChanged { index in
                let weight = TimeInterval(60 * 60 * 24 * 7)

                if index < 1 {
                    // 왼쪽으로 슬라이드
                    timeTableViewModel.currentDate = timeTableViewModel.currentDate
                        .addingTimeInterval(-weight)
                } else if index > 1 {
                    // 오른쪽으로 슬라이드
                    timeTableViewModel.currentDate = timeTableViewModel.currentDate
                        .addingTimeInterval(weight)
                }
                page.update(.new(index: 1))
            }
            .frame(height: topViewHeight)
            .padding(.bottom, 5)

            ScrollView(showsIndicators: false) {
                LazyVGrid(
                    columns: column,
                    spacing: 0
                ) {
                    ForEach(range.indices, id: \.self) { index in
                        if index % 8 == 0 {
                            VStack {
                                Spacer()
                                Text("\(index / 8 + 1)")
                                    .font(.pretendard(size: 12, weight: .regular))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .offset(x: 6, y: 6)
                            }
                        } else {
                            Rectangle()
                                .foregroundColor(.white)
                                .border(
                                    width: 1,
                                    edges: [
                                        .top,
                                        .leading,
                                        (index / 8 == 23) ? .bottom : .top,
                                        (index % 8 == 7) ? .trailing : .leading
                                    ],
                                    color: Color(0xdbdbdb)
                                )
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
                                        let scheduleFormViewModel = ScheduleFormViewModel(
                                            schedule: schedule.data,
                                            categoryList: calendarViewModel.categoryList,
                                            at: schedule.at,
                                            from: .timeTable
                                        ) {
                                            timeTableViewModel.fetchScheduleList()
                                        }

                                        ScheduleFormView(
                                            scheduleFormVM: scheduleFormViewModel,
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

                Spacer(minLength: 80)
            }
        }
        .onAppear {
            calendarViewModel.getCategoryList()
        }
        .padding(.leading, -8)
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
        guard let cellWidth else {
            return nil
        }

        let width = cellWidth * CGFloat(1.0 / Double(weight))

        var x = CGFloat(column) * cellWidth
        x += CGFloat(fixed) + CGFloat(borderWidth * 8) + 0.5
        x -= width == cellWidth ?
            width * 0.5 :
            width * Double(weight) - width * 0.5

        for _ in 1 ..< order {
            x += width
        }

        var y = CGFloat(row) * cellHeight
        y += cellHeight * CGFloat(Double(minuteIndex) * minuteInterval / 60.0) + 1
        y += frame.height * 0.5 - cellHeight

        return (x: x, y: y)
    }

    func calcFrame(
        weight: Int,
        duration: Int = 60
    ) -> (width: CGFloat, height: CGFloat)? {
        guard let cellWidth else {
            return nil
        }

        let width: CGFloat = cellWidth * CGFloat(1.0 / Double(weight)) - 1
        let height: CGFloat = cellHeight * CGFloat(Double(duration) / 60.0) - 1

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

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhh"
        return formatter
    }()

    func dropExited(info: DropInfo) {
        timeTableViewModel.removePreview()
    }

    func dropEntered(info: DropInfo) {
        let year = timeTableViewModel.thisWeek[dayIndex].year
        let month = timeTableViewModel.thisWeek[dayIndex].month
        let day = timeTableViewModel.thisWeek[dayIndex].day
        let components = DateComponents(year: year, month: month, day: day, hour: hourIndex, minute: minuteIndex * 5)
        guard let date = Calendar.current.date(from: components) else {
            return
        }

        timeTableViewModel.insertPreview(date: date)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.text])
    }

    func performDrop(info: DropInfo) -> Bool {
        if timeTableViewModel.draggingSchedule == nil {
            return false
        }

        let year = timeTableViewModel.thisWeek[dayIndex].year
        let month = timeTableViewModel.thisWeek[dayIndex].month
        let day = timeTableViewModel.thisWeek[dayIndex].day
        let components = DateComponents(year: year, month: month, day: day, hour: hourIndex, minute: minuteIndex * 5)
        guard var date = Calendar.current.date(from: components) else {
            return false
        }

        guard let draggingSchedule = timeTableViewModel.draggingSchedule else {
            return false
        }

        let diff = draggingSchedule.data.repeatEnd.diffToMinute(other:
            draggingSchedule.data.repeatStart
        )
        var endDate = date.advanced(by: TimeInterval(60 * diff))

        if date.day != endDate.day {
            var temp = Calendar.current.dateComponents([.year, .month, .day], from: date)
            temp.hour = 23
            temp.minute = 55

            guard let alt = Calendar.current.date(from: temp) else {
                return false
            }
            date = date.advanced(by: -TimeInterval(60 * endDate.diffToMinute(other: alt)))
            endDate = alt
        }

        timeTableViewModel.removePreview()
        if Self.dateFormatter.string(from: draggingSchedule.data.repeatStart) != Self.dateFormatter.string(from: date)
            || draggingSchedule.data.repeatStart.minute / 5 != minuteIndex // 현재 상황에선 해당 줄은 00:04 <-> 00:00 은 같은 위치로 보이기 때문에 업데이트 하지 않음.
        {
            timeTableViewModel.updateDraggingSchedule(
                startDate: date,
                endDate: endDate,
                at: draggingSchedule.at
            )
            return true
        } else {
            timeTableViewModel.findUnion()
        }
        return false
    }
}
