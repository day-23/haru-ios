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
}

final class TimeTableViewModel: ObservableObject {
    private var scheduleService: ScheduleService = .init()
    private var todoService: TodoService = .init()

    @Published var todoListByDate: [[Todo]] = Array(repeating: [], count: 7)
    @Published var scheduleList: [ScheduleCell] = []
    @Published var scheduleListWithoutTime: [[ScheduleCell]] = Array(repeating: [], count: 7)
    var maxRowCount: Int {
        return scheduleListWithoutTime.reduce(0) { acc, curr in
            max(acc, curr.reduce(0) { maxOrder, schedule in
                max(maxOrder, schedule.order)
            })
        }
    }

    @Published var draggingTodo: Todo? = nil
    @Published var draggingSchedule: ScheduleCell? = nil

    @Published var currentDate: Date = .now
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

        scheduleList.append(
            ScheduleCell(
                id: "PREVIEW",
                data: draggingSchedule.data,
                weight: draggingSchedule.weight,
                order: draggingSchedule.order
            )
        )
        let diff = draggingSchedule.data.repeatEnd.diffToMinute(other: draggingSchedule.data.repeatStart)
        scheduleList[scheduleList.count - 1].data.repeatStart = date
        scheduleList[scheduleList.count - 1].data.repeatEnd = date.advanced(by: TimeInterval(60 * diff))
        findUnion()
    }

    func removePreview() {
        scheduleList = scheduleList.filter { $0.id != "PREVIEW" }
    }

    //  MARK: - Read

    func fetchScheduleList() {
        guard let startDate = thisWeek.first,
              let endDate = thisWeek.last?.addingTimeInterval(TimeInterval(60 * 60 * 24 - 1))
        else {
            return
        }

        scheduleService.fetchScheduleList(startDate, endDate) { result in
            switch result {
            case .success(let scheduleList):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"

                self.scheduleList = []
                self.scheduleListWithoutTime = Array(repeating: [], count: 7)
                for schedule in scheduleList {
                    var data = ScheduleCell(id: schedule.id, data: schedule, weight: 1, order: 1)
                    if schedule.isAllDay ||
                        dateFormatter.string(from: schedule.repeatStart) != dateFormatter.string(from: schedule.repeatEnd)
                    {
                        if var start = schedule.repeatStart.indexOfWeek(),
                           var end = schedule.repeatEnd.indexOfWeek()
                        {
                            if schedule.repeatStart.weekOfYear() < self.currentWeek {
                                start = 0
                            }
                            if schedule.repeatEnd.weekOfYear() > self.currentWeek {
                                end = 6
                            }

                            data.weight = end - start + 1
                            self.scheduleListWithoutTime[start].append(data)
                        }
                        continue
                    }
                    self.scheduleList.append(data)
                }
                self.findUnion()
                self.processScheduleListWithoutTime()
            case .failure(let failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
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
                    guard let endDate = todo.endDate,
                          let index = endDate.indexOfWeek()
                    else {
                        continue
                    }
                    self.todoListByDate[index].append(todo)
                }
            case .failure(let failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    //  MARK: - Update

    func updateDraggingSchedule(
        _ startDate: Date,
        _ endDate: Date
    ) {
        guard let draggingSchedule else {
            return
        }

        //  FIXME: - Alarms 데이터 넣어야 함
        scheduleService.updateSchedule(draggingSchedule.id,
                                       Request.Schedule(content: draggingSchedule.data.content,
                                                        memo: draggingSchedule.data.memo,
                                                        isAllDay: draggingSchedule.data.isAllDay,
                                                        repeatStart: startDate,
                                                        repeatEnd: endDate,
                                                        repeatOption: draggingSchedule.data.repeatOption,
                                                        categoryId: draggingSchedule.data.category?.id,
                                                        alarms: draggingSchedule.data.alarms.map(\.time))) { result in
            switch result {
            case .success(let schedule):
                self.draggingSchedule?.data = schedule
                self.scheduleList.append(self.draggingSchedule!)
                self.draggingSchedule = nil
                self.findUnion()
            case .failure(let failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    func updateDraggingTodo(
        index: Int
    ) {
        guard var draggingTodo = draggingTodo else {
            return
        }

        for (i, todoList) in todoListByDate.enumerated() {
            guard let j = todoList.firstIndex(of: draggingTodo) else {
                continue
            }

            //  찾는데 성공하였을 때
            guard let endDate = draggingTodo.endDate else {
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

            todoService.updateTodo(
                todoId: draggingTodo.id,
                todo: Request.Todo(
                    content: draggingTodo.content,
                    memo: draggingTodo.memo,
                    todayTodo: draggingTodo.todayTodo,
                    flag: draggingTodo.flag,
                    endDate: updatedEndDate,
                    isAllDay: draggingTodo.isAllDay,
                    alarms: draggingTodo.alarms.map { $0.time },
                    repeatOption: draggingTodo.repeatOption,
                    repeatValue: draggingTodo.repeatValue,
                    repeatEnd: draggingTodo.repeatEnd,
                    tags: draggingTodo.tags.map { $0.content },
                    subTodos: draggingTodo.subTodos.map { $0.content }
                )
            ) { result in
                switch result {
                case .success:
                    withAnimation {
                        draggingTodo.endDate = updatedEndDate
                        self.todoListByDate[i].remove(at: j)
                        self.todoListByDate[index].append(draggingTodo)
                        self.todoListByDate[index].sort { v1, v2 in
                            guard let endDate1 = v1.endDate,
                                  let endDate2 = v2.endDate
                            else {
                                return false
                            }
                            return endDate1 < endDate2
                        }
                    }
                case .failure(let failure):
                    print("[Debug] \(failure) (\(#fileID), \(#function))")
                }
                self.draggingTodo = nil
            }
            return
        }
    }
}
