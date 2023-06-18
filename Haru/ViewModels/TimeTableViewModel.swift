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

    func isContinuousSchedule(_ schedule: Schedule) -> Bool {
        if let repeatValue = schedule.repeatValue,
           schedule.repeatOption != nil
        {
            return repeatValue.hasPrefix("T")
        }
        return schedule.repeatStart.day != schedule.repeatEnd.day
    }

    func generateRecurringSchedule(_ schedule: Schedule) -> [ScheduleCell] {
        guard let repeatOption = schedule.repeatOption,
              let repeatValue = schedule.repeatValue,
              let first = thisWeek.first,
              let last = thisWeek.last?.addingTimeInterval(60 * 60 * 24 - 1)
        else {
            return []
        }

        var at: RepeatAt = .front
        var schedule: Schedule = schedule
        var schedules: [ScheduleCell] = []

        let repeatEnd = schedule.repeatEnd
        schedule.realRepeatEnd = repeatEnd
        do {
            if isContinuousSchedule(schedule) {
                guard let interval = Double(repeatValue.suffix(repeatValue.count - 1)) else {
                    return []
                }

                schedule.repeatEnd = schedule.repeatStart.addingTimeInterval(TimeInterval(floatLiteral: interval))
                while schedule.repeatStart < first && schedule.repeatEnd < first {
                    schedule.repeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: schedule.repeatStart)
                    schedule.repeatEnd = schedule.repeatStart.addingTimeInterval(TimeInterval(floatLiteral: interval))
                    at = .middle
                }

                if repeatOption == .everyMonth,
                   schedule.repeatStart.month != schedule.repeatEnd.month
                {
                    var components: DateComponents = Calendar.current.dateComponents([.year, .month], from: schedule.repeatStart)
                    guard let range = Calendar.current.range(of: .day, in: .month, for: schedule.repeatStart) else {
                        return []
                    }

                    let upperBound = range.upperBound - 1
                    components.day = upperBound
                    components.hour = 23
                    components.minute = 55

                    guard let newer = Calendar.current.date(from: components) else {
                        return []
                    }
                    schedule.repeatEnd = newer
                }

                while schedule.repeatStart <= last,
                      schedule.repeatStart > first || schedule.repeatEnd > first
                {
                    schedules.append(
                        ScheduleCell(id: "\(schedule.id)-\(schedule.repeatStart)", data: schedule, weight: 1, order: 1, at: at)
                    )

                    guard var start = schedule.repeatStart.indexOfWeek(),
                          var end = schedule.repeatEnd.indexOfWeek()
                    else {
                        return []
                    }

                    if schedule.repeatStart < first {
                        start = 0
                    }
                    if schedule.repeatEnd > last {
                        end = 6
                    }

                    schedules[schedules.count - 1].weight = end - start + 1

                    at = .middle
                    schedule.repeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: schedule.repeatStart)
                    schedule.repeatEnd = schedule.repeatStart.addingTimeInterval(TimeInterval(floatLiteral: interval))
                    let nextRepeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: schedule.repeatStart)
                    if schedule.repeatStart.isEqual(other: repeatEnd)
                        || schedule.repeatEnd > nextRepeatStart
                    {
                        at = .back
                    }

                    if repeatOption == .everyMonth,
                       schedule.repeatStart.month != schedule.repeatEnd.month
                    {
                        var components: DateComponents = Calendar.current.dateComponents([.year, .month], from: schedule.repeatStart)
                        guard let range = Calendar.current.range(of: .day, in: .month, for: schedule.repeatStart) else {
                            return []
                        }

                        let upperBound = range.upperBound - 1
                        components.day = upperBound
                        components.hour = 23
                        components.minute = 55

                        guard let newer = Calendar.current.date(from: components) else {
                            return []
                        }
                        schedule.repeatEnd = newer
                    }
                }
            } else {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: schedule.repeatStart)
                components.hour = repeatEnd.hour
                components.minute = repeatEnd.minute

                guard let newer = Calendar.current.date(from: components) else {
                    return []
                }

                schedule.repeatEnd = newer
                while schedule.repeatStart < first {
                    at = .middle
                    schedule.repeatStart = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatStart)
                    schedule.repeatEnd = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatEnd)
                }

                while schedule.repeatStart <= last,
                      schedule.repeatStart <= repeatEnd
                {
                    if at == .front {
                        let temp = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatStart)
                        let nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: temp)
                        if schedule.repeatStart.isEqual(other: repeatEnd)
                            || repeatEnd < nextRepeatStart
                        {
                            at = .none
                        }
                    }

                    schedules.append(
                        ScheduleCell(id: "\(schedule.id)-\(schedule.repeatStart)", data: schedule, weight: 1, order: 1, at: at)
                    )

                    at = .middle
                    schedule.repeatStart = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatStart)
                    schedule.repeatEnd = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatEnd)
                    let nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatStart)
                    if schedule.repeatStart.isEqual(other: repeatEnd)
                        || repeatEnd < nextRepeatStart
                    {
                        at = .back
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

        return schedules
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
                self.scheduleList = []
                self.scheduleListWithoutTime = Array(repeating: [], count: 7)
                for schedule in scheduleList {
                    let isContinuous = self.isContinuousSchedule(schedule)
                    if schedule.isAllDay || isContinuous {
                        if isContinuous {
                            if schedule.repeatOption != nil {
                                let schedules = self.generateRecurringSchedule(schedule)
                                for recurringSchedule in schedules {
                                    if var start = recurringSchedule.data.repeatStart.indexOfWeek(),
                                       let first = self.thisWeek.first
                                    {
                                        if recurringSchedule.data.repeatStart < first {
                                            start = 0
                                        }
                                        self.scheduleListWithoutTime[start].append(recurringSchedule)
                                    }
                                }
                            } else {
                                if var start = schedule.repeatStart.indexOfWeek(),
                                   var end = schedule.repeatEnd.indexOfWeek(),
                                   let first = self.thisWeek.first,
                                   let last = self.thisWeek.last?.addingTimeInterval(TimeInterval(60 * 60 * 24 - 1))
                                {
                                    var newer = ScheduleCell(id: schedule.id, data: schedule, weight: 1, order: 1)

                                    if schedule.repeatStart < first {
                                        start = 0
                                    }
                                    if schedule.repeatEnd > last {
                                        end = 6
                                    }

                                    newer.weight = end - start + 1
                                    self.scheduleListWithoutTime[start].append(newer)
                                }
                            }
                        } else {
                            if schedule.repeatOption != nil {
                                let schedules = self.generateRecurringSchedule(schedule)
                                for recurringSchedule in schedules {
                                    if let start = recurringSchedule.data.repeatStart.indexOfWeek() {
                                        self.scheduleListWithoutTime[start].append(recurringSchedule)
                                    }
                                }
                            } else {
                                if let start = schedule.repeatStart.indexOfWeek() {
                                    let newer = ScheduleCell(id: schedule.id, data: schedule, weight: 1, order: 1)
                                    self.scheduleListWithoutTime[start].append(newer)
                                }
                            }
                        }
                    } else {
                        if schedule.repeatOption != nil {
                            let schedules = self.generateRecurringSchedule(schedule)
                            self.scheduleList.append(contentsOf: schedules)
                        } else {
                            self.scheduleList.append(
                                ScheduleCell(id: schedule.id, data: schedule, weight: 1, order: 1)
                            )
                        }
                    }
                }
                self.findUnion()
                self.processScheduleListWithoutTime()
            case .failure:
                break
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
                           let last = self.thisWeek.last?.addingTimeInterval(TimeInterval(60 * 60 * 24 - 1))
                        {
                            var at: RepeatAt = .front
                            var modified = todo
                            while endDate < first {
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
                            while endDate <= last {
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
            case .failure:
                break
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
                case .failure:
                    break
                }
            }
        } else {
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
                        curRepeatEnd: draggingSchedule.data.repeatEnd
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
                case .failure:
                    break
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
                    case .failure:
                        break
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
                                case .failure:
                                    break
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
                    case .failure:
                        break
                    }
                }
            }
        }
    }
}
