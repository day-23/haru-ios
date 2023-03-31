//
//  Todo.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct Todo: Identifiable, Codable {
    //  MARK: - Properties

    let id: String
    var content: String
    var memo: String
    var todayTodo: Bool
    var flag: Bool
    var endDate: Date?
    var isAllDay: Bool
    var repeatOption: String?
    var repeatValue: String?
    var repeatEnd: Date?
    var todoOrder: Int?
    var completed: Bool
    var folded: Bool
    var subTodos: [SubTodo]
    var tags: [Tag]
    var alarms: [Alarm]

    //  MARK: - Dates

    let createdAt: Date
    var updatedAt: Date?
    var deletedAt: Date?
}

//  MARK: - Extensions

extension Todo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    //  반복 패턴에 따른 다음 마감일을 계산해주는 함수이다.
    //  만약, 반복이 끝난다면 nil을 리턴한다.
    func nextEndDate() throws -> Date? {
        //  !!!: - 입력시에 마감일이 없으면 어떻게 해결할지에 대해서
        guard let repeatOption = repeatOption,
              let repeatValue = repeatValue,
              let endDate = endDate
        else {
            throw RepeatError.invalid
        }

        let day = 60 * 60 * 24
        let calendar = Calendar.current

        var nextEndDate = endDate

        switch repeatOption {
        case RepeatOption.everyDay.rawValue:
            guard let interval = Int(repeatValue) else { throw RepeatError.invalid }
            nextEndDate = nextEndDate.addingTimeInterval(
                TimeInterval(day * interval)
            )
        case RepeatOption.everyWeek.rawValue:
            let pattern = repeatValue.map { $0 == "1" ? true : false }

            //  pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            var index = calendar.component(.weekday, from: endDate) % 7
            let startIndex = index
            nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))

            while !pattern[index] {
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % 7

                // 한바퀴 돌아서 다시 돌아왔다는 것은 올바르지 않은 입력이다.
                if startIndex == index {
                    throw RepeatError.invalid
                }
            }
        case RepeatOption.everySecondWeek.rawValue:
            let pattern = repeatValue.map { $0 == "1" ? true : false }

            //  pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            var index = calendar.component(.weekday, from: endDate) % 7
            let startIndex = index
            //  만약, 다음 날이 다음 주라면? 현재 기준으로 2주 뒤로 가야함.
            nextEndDate = nextEndDate.addingTimeInterval(
                TimeInterval(day * (index == 0 ? 7 : 1))
            )

            //  반복 패턴이 일치하는지 확인해야 함.
            while !pattern[index] {
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % 7

                //  한 바퀴 돌아서 돌아왔다는 것은, 올바르지 않은 입력이다.
                if startIndex == index {
                    throw RepeatError.invalid
                }

                //  다음 주로 날짜가 바뀌었고 지금까지 일치하지 않았으므로
                //  한 주 더 밀어서 확인해야함.
                if index == 0 {
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                }
            }
        case RepeatOption.everyMonth.rawValue:
            let year = calendar.component(.year, from: endDate)
            let month = calendar.component(.month, from: endDate)

            let dateComponents = DateComponents(year: year, month: month)
            guard let dateInMonth = calendar.date(from: dateComponents),
                  let range = calendar.range(of: .day, in: .month, for: dateInMonth)
            else {
                throw RepeatError.calculation
            }

            let pattern = repeatValue.map { $0 == "1" ? true : false }

            //  pattern 인덱스가 0~30인데, 아래의 반환값은 1~31이므로 다음 날을 가르키게 됨
            let upperBound = range.upperBound - 1
            var index = calendar.component(.day, from: endDate) % upperBound
            let startIndex = index
            nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))

            while !pattern[index] {
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % upperBound

                if index == startIndex {
                    throw RepeatError.invalid
                }
            }
        case RepeatOption.everyYear.rawValue:
            let pattern = repeatValue.map { $0 == "1" ? true : false }

            //  pattern 인덱스가 0~11인데, 아래의 반환값은 1~12이므로 다음 달을 가르키게 됨
            var index = calendar.component(.month, from: endDate) % 12
            if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                nextEndDate = next
            } else {
                throw RepeatError.calculation
            }
            let startIndex = index

            while !pattern[index] {
                if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                    nextEndDate = next
                    index = (index + 1) % 12
                } else {
                    throw RepeatError.calculation
                }

                if startIndex == index {
                    throw RepeatError.invalid
                }
            }
        default:
            throw RepeatError.invalid
        }

        guard let repeatEnd = repeatEnd else {
            return nextEndDate
        }
        return nextEndDate.compare(repeatEnd) == .orderedAscending ? nextEndDate : nil
    }
}

extension Todo: Productivity {}
