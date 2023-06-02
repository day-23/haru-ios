//
//  Todo.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//  Updated by 이준호 on 2023/05/01. createRepeatTodo 함수 작성
//

import Foundation

struct Todo: Identifiable, Codable {
    // MARK: - Properties

    let id: String
    var content: String
    var memo: String
    var todayTodo: Bool
    var flag: Bool
    var endDate: Date?
    var isAllDay: Bool
    var repeatOption: RepeatOption?
    var repeatValue: String?
    var repeatEnd: Date?
    var todoOrder: Int?
    var completed: Bool
    var folded: Bool
    var subTodos: [SubTodo]
    var tags: [Tag]
    var alarms: [Alarm]

    // MARK: - Dates

    let createdAt: Date
    var updatedAt: Date?
    var deletedAt: Date?

    // MARK: 반복 api를 위한 필드 (임의로 프론트에서 넣어주는 값들) 추후에 DTO를 새로 작성할 필요성 있음

    var realRepeatStart: Date?

    init(id: String, content: String, memo: String, todayTodo: Bool, flag: Bool, endDate: Date? = nil, isAllDay: Bool, repeatOption: RepeatOption? = nil, repeatValue: String? = nil, repeatEnd: Date? = nil, todoOrder: Int? = nil, completed: Bool, folded: Bool, subTodos: [SubTodo], tags: [Tag], alarms: [Alarm], createdAt: Date, updatedAt: Date? = nil, deletedAt: Date? = nil, realRepeatStart: Date? = nil) {
        self.id = id
        self.content = content
        self.memo = memo
        self.todayTodo = todayTodo
        self.flag = flag
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.repeatOption = repeatOption
        self.repeatValue = repeatValue
        self.repeatEnd = repeatEnd
        self.todoOrder = todoOrder
        self.completed = completed
        self.folded = folded
        self.subTodos = subTodos
        self.tags = tags
        self.alarms = alarms
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.realRepeatStart = realRepeatStart

        if let alarm = alarms.first {
            Task {
                await AlarmHelper.createNotification(
                    identifier: id,
                    body: content,
                    date: alarm.time
                )
            }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.memo = try container.decode(String.self, forKey: .memo)
        self.todayTodo = try container.decode(Bool.self, forKey: .todayTodo)
        self.flag = try container.decode(Bool.self, forKey: .flag)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        self.isAllDay = try container.decode(Bool.self, forKey: .isAllDay)
        let rawRepeatOption = try container.decodeIfPresent(String.self, forKey: .repeatOption)
        switch rawRepeatOption {
        case RepeatOption.everyDay.rawValue:
            self.repeatOption = .everyDay
        case RepeatOption.everyWeek.rawValue:
            self.repeatOption = .everyWeek
        case RepeatOption.everySecondWeek.rawValue:
            self.repeatOption = .everySecondWeek
        case RepeatOption.everyMonth.rawValue:
            self.repeatOption = .everyMonth
        case RepeatOption.everyYear.rawValue:
            self.repeatOption = .everyYear
        default:
            self.repeatOption = nil
        }
        self.repeatValue = try container.decodeIfPresent(String.self, forKey: .repeatValue)
        self.repeatEnd = try container.decodeIfPresent(Date.self, forKey: .repeatEnd)
        self.todoOrder = try container.decodeIfPresent(Int.self, forKey: .todoOrder)
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.folded = try container.decode(Bool.self, forKey: .folded)
        self.subTodos = try container.decode([SubTodo].self, forKey: .subTodos)
        self.tags = try container.decode([Tag].self, forKey: .tags)
        self.alarms = try container.decode([Alarm].self, forKey: .alarms)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.realRepeatStart = try container.decodeIfPresent(Date.self, forKey: .realRepeatStart)

        let id = self.id
        let content = self.content
        let alarms = self.alarms
        if let alarm = alarms.first {
            Task {
                await AlarmHelper.createNotification(
                    identifier: id,
                    body: content,
                    date: alarm.time
                )
            }
        }
    }

    enum CodingKeys: CodingKey {
        case id
        case content
        case memo
        case todayTodo
        case flag
        case endDate
        case isAllDay
        case repeatOption
        case repeatValue
        case repeatEnd
        case todoOrder
        case completed
        case folded
        case subTodos
        case tags
        case alarms
        case createdAt
        case updatedAt
        case deletedAt
        case realRepeatStart
    }
}

// MARK: - Extensions

extension Todo {
    var at: RepeatAt {
        if self.repeatOption == nil || self.repeatValue == nil {
            return .none
        }

        var nextEndDate: Date?

        do {
            nextEndDate = try self.nextEndDate()
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

        if nextEndDate == nil {
            if self.realRepeatStart == self.endDate {
                return .none
            }
            return .back
        } else if self.realRepeatStart == self.endDate {
            return .front
        } else {
            return .middle
        }
    }
}

extension Todo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.endDate == rhs.endDate
    }
}

extension Todo {
    // 반복 패턴에 따른 다음 마감일을 계산해주는 함수이다.
    // 만약, 반복이 끝난다면 nil을 리턴한다.
    func nextEndDate() throws -> Date? {
        guard let repeatOption,
              let repeatValue,
              let endDate
        else {
            throw RepeatError.invalid
        }

        let dayInSeconds = 60 * 60 * 24
        let calendar = Calendar.current

        var nextEndDate = endDate

        switch repeatOption {
        case .everyDay:
            guard let interval = Int(repeatValue) else { throw RepeatError.invalid }
            nextEndDate = nextEndDate.addingTimeInterval(
                TimeInterval(dayInSeconds * interval)
            )
        case .everyWeek:
            let pattern = repeatValue.map { $0 == "1" ? true : false }

            // pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            var index = calendar.component(.weekday, from: endDate) % 7
            let startIndex = index
            nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(dayInSeconds))

            while !pattern[index] {
                index = (index + 1) % 7
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(dayInSeconds))

                // 한바퀴 돌아서 다시 돌아왔다는 것은 올바르지 않은 입력이다.
                if startIndex == index {
                    throw RepeatError.invalid
                }
            }
        case .everySecondWeek:
            let pattern = repeatValue.map { $0 == "1" ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                throw RepeatError.invalid
            }

            // pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            var index = calendar.component(.weekday, from: endDate) % 7
            let startIndex = index
            // 만약, 다음 날이 다음 주라면? 현재 기준으로 2주 뒤로 가야함.
            nextEndDate = nextEndDate.addingTimeInterval(
                TimeInterval(dayInSeconds * (index == 0 ? 7 : 1))
            )

            // 반복 패턴이 일치하는지 확인해야 함.
            while !pattern[index] {
                index = (index + 1) % 7
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(dayInSeconds))

                // 한 바퀴 돌아서 돌아왔다는 것은, 올바르지 않은 입력이다.
                if startIndex == index {
                    throw RepeatError.invalid
                }

                // 다음 주로 날짜가 바뀌었고 지금까지 일치하지 않았으므로
                // 한 주 더 밀어서 확인해야함.
                if index == 0 {
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(dayInSeconds * 7))
                }
            }
        case .everyMonth:
            guard let range = calendar.range(of: .day, in: .month, for: endDate)
            else {
                throw RepeatError.calculation
            }

            let pattern = repeatValue.map { $0 == "1" ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                throw RepeatError.invalid
            }

            // pattern 인덱스가 0~30인데, 아래의 반환값은 1~31이므로 다음 날을 가르키게 됨
            var upperBound = range.upperBound - 1
            var index = calendar.component(.day, from: endDate) % upperBound
            let startIndex = index
            nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(dayInSeconds))

            if index == 0 {
                guard let range = calendar.range(of: .day, in: .month, for: nextEndDate) else {
                    throw RepeatError.calculation
                }

                upperBound = range.upperBound - 1
            }

            while !pattern[index] {
                index = (index + 1) % upperBound
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(dayInSeconds))

                if index == 0 {
                    guard let range = calendar.range(of: .day, in: .month, for: nextEndDate) else {
                        throw RepeatError.calculation
                    }

                    upperBound = range.upperBound - 1
                }

                if index == startIndex {
                    throw RepeatError.invalid
                }
            }
        case .everyYear:
            let pattern = repeatValue.map { $0 == "1" ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                throw RepeatError.invalid
            }

            if endDate.month == 2, endDate.day == 29, pattern[1] {
                if pattern.filter({ $0 }).count == 1 {
                    let components = DateComponents(
                        year: endDate.year + 4,
                        month: endDate.month,
                        day: endDate.day,
                        hour: endDate.hour,
                        minute: endDate.minute
                    )

                    guard let altNext = Calendar.current.date(from: components) else {
                        throw RepeatError.calculation
                    }
                    nextEndDate = altNext
                    break
                }
            }

            // pattern 인덱스가 0~11인데, 아래의 반환값은 1~12이므로 다음 달을 가르키게 됨
            let day = endDate.day
            var index = calendar.component(.month, from: endDate) % 12
            if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                nextEndDate = next
            } else {
                throw RepeatError.calculation
            }

            let startIndex = index
            while !pattern[index] {
                if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                    guard let range = calendar.range(of: .day, in: .month, for: next) else {
                        throw RepeatError.calculation
                    }

                    let upperBound = range.upperBound - 1
                    let components = DateComponents(
                        year: next.year,
                        month: next.month,
                        day: day <= upperBound ? day : upperBound,
                        hour: endDate.hour,
                        minute: endDate.minute
                    )
                    guard let altNext = calendar.date(from: components) else {
                        throw RepeatError.calculation
                    }

                    index = (index + 1) % 12
                    nextEndDate = altNext
                } else {
                    throw RepeatError.calculation
                }

                if startIndex == index {
                    throw RepeatError.invalid
                }
            }
        }

        guard let repeatEnd else {
            return nextEndDate
        }

        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter
        }()

        return formatter.string(from: nextEndDate) <= formatter.string(from: repeatEnd)
            ? nextEndDate
            : nil
    }
}

extension Todo {
    func prevEndDate() throws -> Date {
        guard let repeatOption,
              let repeatValue,
              let endDate
        else {
            throw RepeatError.invalid
        }

        let dayInSeconds = 60 * 60 * 24
        let calendar = Calendar.current

        var prevEndDate = endDate

        switch repeatOption {
        case .everyDay:
            guard let interval = Int(repeatValue) else { throw RepeatError.invalid }
            prevEndDate = prevEndDate.addingTimeInterval(
                -TimeInterval(dayInSeconds * interval)
            )
        case .everyWeek:
            let pattern = repeatValue.map { $0 == "1" ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                throw RepeatError.invalid
            }

            // pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            // 따라서, -2를 더해줌으로써 어제를 가르키게 한다.
            var index = calendar.component(.weekday, from: endDate) - 2
            if index < 0 {
                index = 6
            }
            let startIndex = index
            prevEndDate = prevEndDate.addingTimeInterval(-TimeInterval(dayInSeconds))

            while !pattern[index] {
                index -= 1
                if index < 0 {
                    index = 6
                }
                prevEndDate = prevEndDate.addingTimeInterval(-TimeInterval(dayInSeconds))

                // 한바퀴 돌아서 다시 돌아왔다는 것은 올바르지 않은 입력이다.
                if startIndex == index {
                    throw RepeatError.invalid
                }
            }
        case .everySecondWeek:
            let pattern = repeatValue.map { $0 == "1" ? true : false }

            // pattern 인덱스가 0~6인데, 아래의 반환값은 1~7이므로 다음 날을 가르키게 됨
            // 따라서, -2를 더해줌으로써 어제를 가르키게 한다.
            var index = calendar.component(.weekday, from: endDate) - 2
            if index < 0 {
                index = 6
            }
            let startIndex = index

            // 만약, 어제가 저번 주라면? 현재 기준으로 2주 앞으로 가야함.
            prevEndDate = prevEndDate.addingTimeInterval(
                -TimeInterval(dayInSeconds * (index == 6 ? 7 : 1))
            )

            // 반복 패턴이 일치하는지 확인해야 함.
            while !pattern[index] {
                index -= 1
                if index < 0 {
                    index = 6
                }
                prevEndDate = prevEndDate.addingTimeInterval(-TimeInterval(dayInSeconds))

                // 한 바퀴 돌아서 돌아왔다는 것은, 올바르지 않은 입력이다.
                if startIndex == index {
                    throw RepeatError.invalid
                }

                // 저번 주로 날짜가 바뀌었고 지금까지 일치하지 않았으므로
                // 한 주 더 밀어서 확인해야함.
                if index == 6 {
                    prevEndDate = prevEndDate.addingTimeInterval(-TimeInterval(dayInSeconds * 7))
                }
            }
        case .everyMonth:
            guard let range = calendar.range(of: .day, in: .month, for: endDate)
            else {
                throw RepeatError.calculation
            }

            let pattern = repeatValue.map { $0 == "1" ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                throw RepeatError.invalid
            }

            // pattern 인덱스가 0~30인데, 아래의 반환값은 1~31이므로 다음 날을 가르키게 됨
            // 따라서, -2를 더해줌으로써 어제를 가르키게 한다.
            var upperBound = range.upperBound - 1
            var index = calendar.component(.day, from: endDate) - 2
            prevEndDate = prevEndDate.addingTimeInterval(-TimeInterval(dayInSeconds))
            if index < 0 {
                guard let range = calendar.range(of: .day, in: .month, for: prevEndDate) else {
                    throw RepeatError.calculation
                }

                upperBound = range.upperBound - 1
                index = upperBound
            }
            let startIndex = index

            while !pattern[index] {
                index -= 1
                prevEndDate = prevEndDate.addingTimeInterval(-TimeInterval(dayInSeconds))
                if index < 0 {
                    guard let range = calendar.range(of: .day, in: .month, for: prevEndDate) else {
                        throw RepeatError.calculation
                    }

                    upperBound = range.upperBound - 1
                    index = upperBound
                }

                if index == startIndex {
                    throw RepeatError.invalid
                }
            }
        case .everyYear:
            let pattern = repeatValue.map { $0 == "1" ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                throw RepeatError.invalid
            }

            if endDate.month == 2, endDate.day == 29, pattern[1] {
                if pattern.filter({ $0 }).count == 1 {
                    let components = DateComponents(
                        year: endDate.year - 4,
                        month: endDate.month,
                        day: endDate.day,
                        hour: endDate.hour,
                        minute: endDate.minute
                    )

                    guard let altPrev = Calendar.current.date(from: components) else {
                        throw RepeatError.calculation
                    }
                    prevEndDate = altPrev
                    break
                }
            }

            // pattern 인덱스가 0~11인데, 아래의 반환값은 1~12이므로 다음 달을 가르키게 됨
            // 따라서, 이전 달을 가르키기 위해 -2를 더한다.
            let day = endDate.day
            var index = calendar.component(.month, from: endDate) - 2
            if index < 0 {
                index = 11
            }
            if let prev = calendar.date(byAdding: .month, value: -1, to: prevEndDate) {
                prevEndDate = prev
            } else {
                throw RepeatError.calculation
            }
            let startIndex = index

            while !pattern[index] {
                if let prev = calendar.date(byAdding: .month, value: -1, to: prevEndDate) {
                    guard let range = calendar.range(of: .day, in: .month, for: prev) else {
                        throw RepeatError.calculation
                    }

                    let upperBound = range.upperBound - 1
                    let components = DateComponents(
                        year: prev.year,
                        month: prev.month,
                        day: day <= upperBound ? day : upperBound,
                        hour: endDate.hour,
                        minute: endDate.minute
                    )
                    guard let altPrev = calendar.date(from: components) else {
                        throw RepeatError.calculation
                    }

                    index -= 1
                    if index < 0 {
                        index = 11
                    }
                    prevEndDate = altPrev
                } else {
                    throw RepeatError.calculation
                }

                if startIndex == index {
                    throw RepeatError.invalid
                }
            }
        }

        return prevEndDate
    }
}

extension Todo {
    static func createRepeatTodo(
        todo: Todo,
        endDate: Date,
        realRepeatStart: Date? = nil
    ) -> Todo {
        Todo(
            id: todo.id,
            content: todo.content,
            memo: todo.memo,
            todayTodo: todo.todayTodo,
            flag: todo.flag,
            endDate: endDate,
            isAllDay: todo.isAllDay,
            repeatOption: todo.repeatOption,
            repeatValue: todo.repeatValue,
            repeatEnd: todo.repeatEnd,
            todoOrder: todo.todoOrder,
            completed: todo.completed,
            folded: todo.folded,
            subTodos: todo.subTodos,
            tags: todo.tags,
            alarms: todo.alarms,
            createdAt: todo.createdAt,
            realRepeatStart: realRepeatStart ?? todo.endDate
        )
    }
}

extension Todo: Event {}
