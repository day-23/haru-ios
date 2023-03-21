//
//  Todo.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct Todo: Identifiable, Codable {
    // MARK: - Properties

    let id: String
    private(set) var content: String
    private(set) var memo: String
    private(set) var todayTodo: Bool
    private(set) var flag: Bool
    private(set) var repeatOption: String?
    private(set) var repeatValue: String?
    private(set) var alarms: [Alarm]
    private(set) var endDate: Date?
    private(set) var endDateTime: Date?
    private(set) var repeatEnd: Date?
    private(set) var todoOrder: Int?
    private(set) var todayTodoOrder: Int?
    private(set) var nextSubTodoOrder: Int?
    private(set) var completed: Bool
    var subTodos: [SubTodo]
    private(set) var tags: [Tag]

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date?
    private(set) var deletedAt: Date?
}

// MARK: - Extensions

extension Todo {
    func nextEndDate() -> Date? {
        guard let repeatOption = repeatOption,
              let repeatValue = repeatValue,
              let endDate = endDate
        else {
            return nil
        }

        let day = 60 * 60 * 24
        let calendar = Calendar.current

        var nextEndDate = endDate

        switch repeatOption {
        case RepeatOption.everyDay.rawValue:
            guard let interval = Int(repeatValue) else { return nil }
            nextEndDate = nextEndDate.addingTimeInterval(
                TimeInterval(day * interval)
            )
        case RepeatOption.everyWeek.rawValue:
            //  pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            var index = calendar.component(.weekday, from: endDate)
            let startIndex = index - 1
            let pattern = repeatValue.map { $0 == "1" ? true : false }
            while !pattern[index % 7] {
                nextEndDate = nextEndDate.addingTimeInterval(
                    TimeInterval(day)
                )
                index += 1

                if startIndex == index % 7 {
                    return nil
                }
            }
        case RepeatOption.everySecondWeek.rawValue:
            //  pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            var index = calendar.component(.weekday, from: endDate)
            let pattern = repeatValue.map { $0 == "1" ? true : false }
            while !pattern[index], index < 7 {
                nextEndDate = nextEndDate.addingTimeInterval(
                    TimeInterval(day)
                )
                index += 1
            }

            // 한 주를 미뤄야 함
            if index == 7 {
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                index = 0
                while !pattern[index] {
                    nextEndDate = nextEndDate.addingTimeInterval(
                        TimeInterval(day)
                    )
                    index += 1

                    if index == 0 {
                        return nil
                    }
                }
            }
        case RepeatOption.everyMonth.rawValue:
            let year = calendar.component(.year, from: endDate)
            let month = calendar.component(.month, from: endDate)

            let dateComponents = DateComponents(year: year, month: month)
            guard let dateInMonth = calendar.date(from: dateComponents),
                  let range = calendar.range(of: .day, in: .month, for: dateInMonth),
                  let lastDay = calendar.date(from: DateComponents(year: year, month: month, day: range.upperBound))
            else {
                return nil
            }

            let pattern = repeatValue.map { $0 == "1" ? true : false }

            //  pattern 인덱스가 0~30인데, 아래의 반환값은 1~31이므로 다음 날을 가르키게 됨
            var index = calendar.component(.day, from: endDate)
            var lastIndex = calendar.component(.day, from: lastDay)
            let startIndex = index - 1
            while !pattern[index] {
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                index += 1

                if index > lastIndex {
                    index = 0
                }
                if index == startIndex {
                    return nil
                }
            }
        case RepeatOption.everyYear.rawValue:
            let pattern = repeatValue.map { $0 == "1" ? true : false }

            //  pattern 인덱스가 0~11인데, 아래의 반환값은 1~12이므로 다음 달을 가르키게 됨
            var index = calendar.component(.month, from: endDate)
            let startIndex = index - 1
            while !pattern[index] {
                if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                    nextEndDate = next
                    index += 1
                } else {
                    return nil
                }

                if startIndex == index % 12 {
                    return nil
                }
            }
        default:
            return nil
        }

        return nextEndDate
    }
}
