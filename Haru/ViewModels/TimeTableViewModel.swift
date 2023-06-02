//
//  TimeTableViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import Foundation
import SwiftUI

struct ScheduleCell: Identifiable {
    var id: String
    var data: Schedule
    var weight: Int
    var order: Int
    var at: RepeatAt = .none
}

struct TodoCell: Identifiable, Equatable {
    var id: String
    var data: Todo
    var at: RepeatAt = .none

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.data == rhs.data
    }
}

final class TimeTableViewModel: ObservableObject {
    private var scheduleService: ScheduleService = .init()
    private var todoService: TodoService = .init()

    @Published var todoListByDate: [[TodoCell]] = Array(repeating: [], count: 7)

    @Published var scheduleList: [ScheduleCell] = []

    @Published var scheduleListWithoutTime: [[ScheduleCell]] = Array(repeating: [], count: 7)
    var maxRowCount: Int {
        scheduleListWithoutTime.reduce(0) { acc, curr in
            max(acc, curr.reduce(0) { maxOrder, schedule in
                max(maxOrder, schedule.order)
            })
        }
    }

    @Published var draggingTodo: TodoCell? = nil
    @Published var draggingSchedule: ScheduleCell? = nil

    @Published var currentDate: Date = .now {
        didSet {
            fetchTodoList()
            fetchScheduleList()
        }
    }

    var currentYear: Int { currentDate.year }
    var currentMonth: Int { currentDate.month }
    var currentWeek: Int { currentDate.weekOfYear() }

    var thisWeek: [Date] {
        let calendar = Calendar.current

        // 해당 연도와 주차로 해당 주의 첫 번째 날짜를 가져옵니다.
        guard var dayOfWeek = calendar.date(from: DateComponents(weekOfYear: currentWeek, yearForWeekOfYear: currentYear)) else {
            return []
        }

        var result: [Date] = []
        for _ in 0 ... 6 {
            result.append(dayOfWeek)
            dayOfWeek = dayOfWeek.addDay()
        }
        return result
    }

    @Published var indices: [Int] = [-1, 0, 1]

    func processScheduleListWithoutTime() {
        struct Point: Hashable {
            let r: Int
            let c: Int
        }

        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyyMMddHHmmss"

        for (index, scheduleList) in scheduleListWithoutTime.enumerated() {
            scheduleListWithoutTime[index] = scheduleList.sorted(by: { first, second in
                if first.data.isAllDay {
                    return true
                } else if second.data.isAllDay {
                    return false
                }

                return dateTimeFormatter.string(from: first.data.repeatStart) < dateTimeFormatter.string(from: second.data.repeatStart)
            })
        }

        var orderSet: Set<Point> = []
        for (c, scheduleList) in scheduleListWithoutTime.enumerated() {
            for (r, scheduleCell) in scheduleList.enumerated() {
                if orderSet.contains(Point(r: r, c: c)) {
                    var nr = r + 1
                    while orderSet.contains(Point(r: nr, c: c)) {
                        nr += 1
                    }
                    for x in c ..< c + scheduleCell.weight {
                        orderSet.insert(Point(r: nr, c: x))
                    }
                    scheduleListWithoutTime[c][r].order = nr + 1
                } else {
                    for x in c ..< c + scheduleCell.weight {
                        orderSet.insert(Point(r: r, c: x))
                    }
                    scheduleListWithoutTime[c][r].order = r + 1
                }
            }
        }
    }

    func findUnion() {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyyMMddHHmmss"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"

        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "mm"

        var parent: [Int] = []
        for index in scheduleList.indices { parent.append(index) }

        scheduleList.sort { lvalue, rvalue in
            dateTimeFormatter.string(from: lvalue.data.repeatStart) < dateTimeFormatter.string(from: rvalue.data.repeatStart)
        }

        for i in scheduleList.indices {
            scheduleList[i].weight = 1
            scheduleList[i].order = 1

            for j in i + 1 ..< scheduleList.count {
                let date1 = scheduleList[i].data.repeatEnd
                let date2 = scheduleList[j].data.repeatStart

                if dateFormatter.string(from: date1) != dateFormatter.string(from: date2) {
                    break
                }

                let hour1 = hourFormatter.string(from: date1)
                let hour2 = hourFormatter.string(from: date2)

                if hour1 < hour2 {
                    break
                } else if hour1 == hour2 {
                    let minute1 = minuteFormatter.string(from: date1)
                    let minute2 = minuteFormatter.string(from: date2)

                    if minute1 <= minute2 {
                        break
                    }
                }

                unionMerge(parent: &parent, x: i, y: j)
            }
        }

        var set: [[Int]] = Array(repeating: [], count: scheduleList.count)
        for j in scheduleList.indices {
            parent[j] = unionFind(parent: &parent, x: j)
            set[parent[j]].append(j)
        }

        for j in set.indices {
            for (order, index) in zip(set[j].indices, set[j]) {
                scheduleList[index].weight = set[j].count
                scheduleList[index].order = order + 1
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
            parent[y] = x
        } else {
            parent[x] = y
        }
    }

    func insertPreview(
        date: Date
    ) {
        guard let draggingSchedule else {
            return
        }

        let diff = draggingSchedule.data.repeatEnd.diffToMinute(other: draggingSchedule.data.repeatStart)
        var endDate = date.advanced(by: TimeInterval(60 * diff))

        scheduleList.append(
            ScheduleCell(
                id: "PREVIEW",
                data: draggingSchedule.data,
                weight: draggingSchedule.weight,
                order: draggingSchedule.order
            )
        )

        var date = date
        if date.day != endDate.day {
            var temp = Calendar.current.dateComponents([.year, .month, .day], from: date)
            temp.hour = 23
            temp.minute = 55

            guard let alt = Calendar.current.date(from: temp) else {
                return
            }
            date = date.advanced(by: -TimeInterval(60 * endDate.diffToMinute(other: alt)))
            endDate = alt
        }
        scheduleList[scheduleList.count - 1].data.repeatStart = date
        scheduleList[scheduleList.count - 1].data.repeatEnd = endDate
        findUnion()
    }

    func removePreview() {
        scheduleList = scheduleList.filter { $0.id != "PREVIEW" }
    }

    // MARK: - Read

    func fetchScheduleList() {
        guard let startDate = thisWeek.first,
              let endDate = thisWeek.last?.addingTimeInterval(TimeInterval(60 * 60 * 24 - 1))
        else {
            return
        }

        scheduleService.fetchScheduleList(
            startDate, endDate
        ) { result in
            switch result {
            case .success(let scheduleList):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"

                self.scheduleList = []
                self.scheduleListWithoutTime = Array(repeating: [], count: 7)
                for schedule in scheduleList {
                    var data = ScheduleCell(id: schedule.id, data: schedule, weight: 1, order: 1)

                    // 반복 일정이 아니면서 Schedule이 하루 종일이거나, 시작 날짜와 끝 날짜가 다를 경우.
                    if schedule.repeatOption == nil,
                       schedule.isAllDay
                       || dateFormatter.string(from: schedule.repeatStart) != dateFormatter.string(from: schedule.repeatEnd)
                    {
                        if var start = schedule.repeatStart.indexOfWeek(),
                           var end = schedule.repeatEnd.indexOfWeek()
                        {
                            if schedule.repeatStart.year < self.currentYear {
                                start = 0
                            } else if schedule.repeatStart.year == self.currentYear,
                                      schedule.repeatStart.weekOfYear() < self.currentWeek
                            {
                                start = 0
                            }

                            if schedule.repeatEnd.year == self.currentYear,
                               schedule.repeatEnd.weekOfYear() > self.currentWeek
                            {
                                end = 6
                            } else if schedule.repeatEnd.year > self.currentYear {
                                end = 6
                            }

                            data.weight = end - start + 1
                            self.scheduleListWithoutTime[start].append(data)
                        }
                        continue
                    }

                    // Schedule이 반복 일정일 경우
                    if schedule.repeatOption != nil {
                        if let first = self.thisWeek.first,
                           let last = self.thisWeek.last,
                           let repeatValue = schedule.repeatValue
                        {
                            var repeatSchedule = schedule
                            if !repeatValue.hasPrefix("T") {
                                // 단일 날짜 일정
                                var at: RepeatAt = .front

                                while dateFormatter.string(from: repeatSchedule.repeatStart) <= dateFormatter.string(from: last),
                                      dateFormatter.string(from: repeatSchedule.repeatStart) <= dateFormatter.string(from: schedule.repeatEnd)
                                {
                                    let dateComponents = DateComponents(
                                        year: repeatSchedule.repeatStart.year,
                                        month: repeatSchedule.repeatStart.month,
                                        day: repeatSchedule.repeatStart.day,
                                        hour: schedule.repeatEnd.hour,
                                        minute: schedule.repeatEnd.minute
                                    )

                                    guard let repeatEnd = Calendar.current.date(from: dateComponents)
                                    else {
                                        return
                                    }
                                    repeatSchedule.repeatEnd = repeatEnd
                                    repeatSchedule.realRepeatEnd = schedule.repeatEnd

                                    if at == .front {
                                        do {
                                            let temp = try schedule.nextRepeatStartDate(curRepeatStart: repeatSchedule.repeatStart)
                                            if dateFormatter.string(from: schedule.repeatEnd) < dateFormatter.string(from: temp)
                                            {
                                                at = .none
                                            }
                                        } catch {
                                            switch error {
                                            case RepeatError.invalid:
                                                print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                                            case RepeatError.calculation:
                                                print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                                            default:
                                                print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                                            }
                                        }
                                    }

                                    // 만약 반복일 계산 결과가 이번 주의 안으로 오지 않는다면 버린다.
                                    if dateFormatter.string(from: first) > dateFormatter.string(from: repeatSchedule.repeatStart)
                                        || dateFormatter.string(from: last) < dateFormatter.string(from: repeatSchedule.repeatStart)
                                    {
                                        break
                                    }

                                    let cell = ScheduleCell(
                                        id: UUID().uuidString,
                                        data: repeatSchedule,
                                        weight: 1,
                                        order: 1,
                                        at: at
                                    )

                                    if repeatSchedule.isAllDay {
                                        if let start = repeatSchedule.repeatStart.indexOfWeek() {
                                            self.scheduleListWithoutTime[start].append(cell)
                                        }
                                    } else {
                                        self.scheduleList.append(cell)
                                    }

                                    do {
                                        repeatSchedule.repeatStart = try schedule.nextRepeatStartDate(curRepeatStart: repeatSchedule.repeatStart)
                                        let next = try schedule.nextRepeatStartDate(curRepeatStart: repeatSchedule.repeatStart)
                                        at = .middle
                                        if dateFormatter.string(from: schedule.repeatEnd) == dateFormatter.string(from: repeatSchedule.repeatStart)
                                            || dateFormatter.string(from: schedule.repeatEnd) < dateFormatter.string(from: next)
                                        {
                                            at = .back
                                        }
                                    } catch {
                                        switch error {
                                        case RepeatError.invalid:
                                            print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                                        case RepeatError.calculation:
                                            print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                                        default:
                                            print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                                        }
                                    }
                                }
                            } else {
                                var at: RepeatAt = .front
                                // 2일 연속 일정

                                while dateFormatter.string(from: repeatSchedule.repeatStart) < dateFormatter.string(from: first),
                                      dateFormatter.string(from: repeatSchedule.repeatStart) < dateFormatter.string(from: repeatSchedule.repeatEnd)
                                {
                                    do {
                                        repeatSchedule.repeatStart = try repeatSchedule.nextSucRepeatStartDate(curRepeatStart: repeatSchedule.repeatStart)
                                        at = .middle

                                        let next = try repeatSchedule.nextSucRepeatStartDate(curRepeatStart: repeatSchedule.repeatStart)
                                        if next > repeatSchedule.repeatEnd {
                                            at = .back
                                        }
                                    } catch {
                                        switch error {
                                        case RepeatError.invalid:
                                            print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                                        case RepeatError.calculation:
                                            print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                                        default:
                                            print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                                        }
                                    }
                                }

                                // 만약 반복일 계산 결과가 이번 주의 마지막을 넘어선다면 다음으로 넘어간다.
                                if dateFormatter.string(from: last) < dateFormatter.string(from: repeatSchedule.repeatStart) {
                                    continue
                                }

                                // interval을 이용 repeatEnd를 계산한다.
                                guard let interval = Double(
                                    repeatValue[
                                        repeatValue.index(repeatValue.startIndex, offsetBy: 1)...
                                    ]
                                )
                                else {
                                    continue
                                }

                                let repeatEnd = repeatSchedule.repeatStart.addingTimeInterval(
                                    TimeInterval(floatLiteral: interval)
                                )
                                repeatSchedule.repeatEnd = repeatEnd
                                repeatSchedule.realRepeatEnd = schedule.repeatEnd

                                if repeatSchedule.repeatStart.month != repeatSchedule.repeatEnd.month {
                                    guard let range = Calendar.current.range(
                                        of: .day,
                                        in: .month,
                                        for: repeatSchedule.repeatStart
                                    ) else {
                                        continue
                                    }

                                    let upperBound = range.upperBound - 1
                                    var components = Calendar.current.dateComponents(
                                        [.year, .month, .day, .hour, .minute],
                                        from: repeatSchedule.repeatStart
                                    )
                                    components.month = repeatSchedule.repeatStart.month
                                    components.day = upperBound
                                    components.hour = 23
                                    components.minute = 55

                                    guard let upperDate = Calendar.current.date(from: components) else {
                                        continue
                                    }

                                    repeatSchedule.repeatEnd = upperDate
                                }

                                if var start = repeatSchedule.repeatStart.indexOfWeek(),
                                   var end = repeatSchedule.repeatEnd.indexOfWeek()
                                {
                                    if repeatSchedule.repeatStart.year < self.currentYear {
                                        start = 0
                                    } else if repeatSchedule.repeatStart.year == self.currentYear,
                                              repeatSchedule.repeatStart.weekOfYear() < self.currentWeek
                                    {
                                        start = 0
                                    }

                                    if repeatSchedule.repeatEnd.year == self.currentYear,
                                       repeatSchedule.repeatEnd.weekOfYear() > self.currentWeek
                                    {
                                        end = 6
                                    } else if repeatSchedule.repeatEnd.year > self.currentYear {
                                        end = 6
                                    }

                                    data.at = at
                                    data.weight = end - start + 1
                                    self.scheduleListWithoutTime[start].append(data)
                                }
                            }
                        }
                        continue
                    }

                    // 위의 모든 경우가 아닌 경우
                    self.scheduleList.append(data)
                }
                self.findUnion()
                self.processScheduleListWithoutTime()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTodoList() {
        guard let startDate = thisWeek.first,
              let endDate = thisWeek.last?.addingTimeInterval(TimeInterval(60 * 60 * 24 - 1))
        else {
            return
        }

        todoService.fetchTodoListByRange(
            startDate: startDate,
            endDate: endDate
        ) { result in
            switch result {
            case .success(let todoList):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"

                self.todoListByDate = Array(repeating: [], count: 7)
                for todo in todoList {
                    guard var endDate = todo.endDate else {
                        continue
                    }
                    if todo.completed {
                        continue
                    }

                    if todo.repeatOption != nil {
                        if let first = self.thisWeek.first,
                           let last = self.thisWeek.last
                        {
                            var at: RepeatAt = .front
                            var modified = todo
                            while dateFormatter.string(from: endDate) < dateFormatter.string(from: first) {
                                do {
                                    guard let next = try modified.nextEndDate() else {
                                        // 반복이 끝난 할 일
                                        at = .back
                                        break
                                    }

                                    endDate = next
                                    modified.endDate = endDate
                                    at = .middle
                                } catch {
                                    switch error {
                                    case RepeatError.invalid:
                                        print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                                    case RepeatError.calculation:
                                        print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                                    default:
                                        print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                                    }
                                }
                            }

                            // 데이터 추가
                            while dateFormatter.string(from: endDate) <= dateFormatter.string(from: last) {
                                guard let index = endDate.indexOfWeek() else {
                                    continue
                                }

                                do {
                                    guard let next = try modified.nextEndDate() else {
                                        // 반복이 끝난 할 일
                                        self.todoListByDate[index].append(
                                            TodoCell(
                                                id: UUID().uuidString,
                                                data: modified,
                                                at: at == .front ? .none : .back
                                            )
                                        )
                                        break
                                    }

                                    self.todoListByDate[index].append(
                                        TodoCell(
                                            id: UUID().uuidString,
                                            data: modified,
                                            at: at
                                        )
                                    )
                                    endDate = next
                                    modified.endDate = endDate
                                    at = .middle
                                } catch {
                                    switch error {
                                    case RepeatError.invalid:
                                        print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                                    case RepeatError.calculation:
                                        print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                                    default:
                                        print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                                    }
                                }
                            }
                        }
                    } else {
                        guard let index = endDate.indexOfWeek() else {
                            continue
                        }

                        self.todoListByDate[index].append(
                            TodoCell(id: todo.id, data: todo)
                        )
                    }
                }
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // MARK: - Update

    func updateDraggingSchedule(
        startDate: Date,
        endDate: Date,
        at: RepeatAt
    ) {
        guard let draggingSchedule else {
            return
        }
        scheduleList = scheduleList.filter { $0.id != draggingSchedule.id }

        // TODO: - front == back 처리 필요
        if at == .none {
            scheduleService.updateSchedule(
                scheduleId: draggingSchedule.data.id,
                schedule: Request.Schedule(
                    content: draggingSchedule.data.content,
                    memo: draggingSchedule.data.memo,
                    isAllDay: draggingSchedule.data.isAllDay,
                    repeatStart: startDate,
                    repeatEnd: endDate,
                    repeatOption: draggingSchedule.data.repeatOption,
                    repeatValue: draggingSchedule.data.repeatValue,
                    categoryId: draggingSchedule.data.category?.id,
                    alarms: draggingSchedule.data.alarms.map(\.time)
                )
            ) { result in
                switch result {
                case .success(let schedule):
                    self.draggingSchedule?.data = schedule
                    self.scheduleList.append(self.draggingSchedule!)
                    self.draggingSchedule = nil
                    self.findUnion()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else {
            if at == .none {
                print("[Debug] at의 값이 none입니다. \(#fileID), \(#function)")
                return
            }

            var nextRepeatStart: Date? {
                if !(at == .front || at == .middle) {
                    return nil
                }

                var date: Date?
                do {
                    date = try draggingSchedule.data.nextRepeatStartDate(
                        curRepeatStart: draggingSchedule.data.repeatStart
                    )
                } catch {
                    switch error {
                    case RepeatError.invalid:
                        print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                    case RepeatError.calculation:
                        print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                    default:
                        print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                    }
                }
                return date
            }

            var changedDate: Date? {
                if at != .middle {
                    return nil
                }
                return draggingSchedule.data.repeatStart
            }

            var preRepeatEnd: Date? {
                if at != .back {
                    return nil
                }

                var date: Date?
                do {
                    date = try draggingSchedule.data.prevRepeatEndDate(
                        curRepeatEnd: draggingSchedule.data.repeatStart
                    )

                    let components = DateComponents(
                        year: date?.year,
                        month: date?.month,
                        day: date?.day,
                        hour: draggingSchedule.data.repeatEnd.hour,
                        minute: draggingSchedule.data.repeatEnd.minute
                    )

                    guard let repeatEnd = Calendar.current.date(from: components) else {
                        return nil
                    }
                    return repeatEnd
                } catch {
                    switch error {
                    case RepeatError.invalid:
                        print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                    case RepeatError.calculation:
                        print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                    default:
                        print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                    }
                }
                return date
            }
            scheduleService.updateScheduleWithRepeat(
                scheduleId: draggingSchedule.data.id,
                schedule: Request.RepeatSchedule(
                    content: draggingSchedule.data.content,
                    memo: draggingSchedule.data.memo,
                    isAllDay: draggingSchedule.data.isAllDay,
                    repeatStart: startDate,
                    repeatEnd: endDate,
                    repeatOption: nil,
                    repeatValue: nil,
                    categoryId: draggingSchedule.data.category?.id,
                    alarms: draggingSchedule.data.alarms.map(\.time),
                    nextRepeatStart: nextRepeatStart,
                    changedDate: changedDate,
                    preRepeatEnd: preRepeatEnd
                ),
                at: draggingSchedule.at
            ) { result in
                switch result {
                case .success:
                    self.draggingSchedule = nil
                    self.fetchScheduleList()
                case .failure(let error):
                    print("[Debug] \(error) \(#fileID) \(#function)")
                }
            }
        }
    }

    func updateDraggingTodo(
        index: Int
    ) {
        guard var draggingTodo else {
            return
        }

        for (i, todoList) in todoListByDate.enumerated() {
            guard let j = todoList.firstIndex(of: draggingTodo) else {
                continue
            }

            // 찾는데 성공하였을 때
            guard let endDate = draggingTodo.data.endDate else {
                return
            }

            let date = thisWeek[index]
            let components = DateComponents(
                year: date.year,
                month: date.month,
                day: date.day,
                hour: endDate.hour,
                minute: endDate.minute,
                second: endDate.second
            )

            guard let updatedEndDate = Calendar.current.date(from: components) else {
                return
            }

            if draggingTodo.at == .none {
                todoService.updateTodo(
                    todoId: draggingTodo.data.id,
                    todo: Request.Todo(
                        content: draggingTodo.data.content,
                        memo: draggingTodo.data.memo,
                        todayTodo: draggingTodo.data.todayTodo,
                        flag: draggingTodo.data.flag,
                        endDate: updatedEndDate,
                        isAllDay: draggingTodo.data.isAllDay,
                        alarms: draggingTodo.data.alarms.map(\.time),
                        repeatOption: draggingTodo.data.repeatOption,
                        repeatValue: draggingTodo.data.repeatValue,
                        repeatEnd: draggingTodo.data.repeatEnd,
                        tags: draggingTodo.data.tags.map(\.content),
                        subTodos: draggingTodo.data.subTodos.map(\.content),
                        subTodosCompleted: draggingTodo.data.subTodos.map(\.completed)
                    )
                ) { result in
                    switch result {
                    case .success:
                        withAnimation {
                            draggingTodo.data.endDate = updatedEndDate
                            self.todoListByDate[i].remove(at: j)
                            self.todoListByDate[index].append(draggingTodo)
                            self.todoListByDate[index].sort { v1, v2 in
                                guard let endDate1 = v1.data.endDate,
                                      let endDate2 = v2.data.endDate
                                else {
                                    return false
                                }
                                return endDate1 < endDate2
                            }
                        }
                    case .failure(let error):
                        print("[Debug] \(error) \(#fileID) \(#function)")
                    }
                    self.draggingTodo = nil
                }
            } else {
                var date: Date = .now
                if draggingTodo.at == .front || draggingTodo.at == .middle {
                    do {
                        if let nextEndDate = try draggingTodo.data.nextEndDate() {
                            date = nextEndDate
                        } else {
                            todoService.updateTodo(
                                todoId: draggingTodo.data.id,
                                todo: Request.Todo(
                                    content: draggingTodo.data.content,
                                    memo: draggingTodo.data.memo,
                                    todayTodo: draggingTodo.data.todayTodo,
                                    flag: draggingTodo.data.flag,
                                    endDate: updatedEndDate,
                                    isAllDay: draggingTodo.data.isAllDay,
                                    alarms: draggingTodo.data.alarms.map(\.time),
                                    repeatOption: nil,
                                    repeatValue: nil,
                                    repeatEnd: nil,
                                    tags: draggingTodo.data.tags.map(\.content),
                                    subTodos: draggingTodo.data.subTodos.map(\.content),
                                    subTodosCompleted: draggingTodo.data.subTodos.map(\.completed)
                                )
                            ) { result in
                                switch result {
                                case .success:
                                    self.fetchTodoList()
                                case .failure(let error):
                                    print("[Debug] \(error) \(#fileID), \(#function)")
                                }
                            }
                        }
                    } catch {
                        switch error {
                        case RepeatError.invalid:
                            print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                        case RepeatError.calculation:
                            print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                        default:
                            print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                        }
                    }
                } else if draggingTodo.at == .back {
                    do {
                        date = try draggingTodo.data.prevEndDate()
                    } catch {
                        switch error {
                        case RepeatError.invalid:
                            print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                        case RepeatError.calculation:
                            print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                        default:
                            print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                        }
                    }
                }

                todoService.updateTodoWithRepeat(
                    todoId: draggingTodo.data.id,
                    todo: Request.Todo(
                        content: draggingTodo.data.content,
                        memo: draggingTodo.data.memo,
                        todayTodo: draggingTodo.data.todayTodo,
                        flag: draggingTodo.data.flag,
                        endDate: updatedEndDate,
                        isAllDay: draggingTodo.data.isAllDay,
                        alarms: draggingTodo.data.alarms.map(\.time),
                        repeatOption: nil,
                        repeatValue: nil,
                        repeatEnd: nil,
                        tags: draggingTodo.data.tags.map(\.content),
                        subTodos: draggingTodo.data.subTodos.map(\.content),
                        subTodosCompleted: draggingTodo.data.subTodos.map(\.completed)
                    ),
                    date: date,
                    at: draggingTodo.at
                ) { result in
                    switch result {
                    case .success:
                        self.fetchTodoList()
                    case .failure(let error):
                        print("[Debug] \(error) \(#fileID), \(#function)")
                    }
                }
            }
        }
    }
}
