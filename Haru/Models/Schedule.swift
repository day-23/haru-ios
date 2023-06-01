//
//  Schedule.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//  Updated by 최정민 on 2023/05/31.
//

import Foundation

struct Schedule: Identifiable, Codable {
    let id: String
    var content: String // 일정 제목
    var memo: String
    var isAllDay: Bool

    var repeatStart: Date
    var repeatEnd: Date

    var repeatOption: String?
    var repeatValue: String?

    var category: Category?

    var alarms: [Alarm] // 알람이 설정되었는가? => !alarms.isEmpty

    // MARK: - Dates

    let createdAt: Date?
    var updatedAt: Date?

    // MARK: 반복 api를 위한 필드 (임의로 프론트에서 넣어주는 값들) 추후에 DTO를 새로 작성할 필요성 있음

    var realRepeatStart: Date?
    var realRepeatEnd: Date?

    var prevRepeatEnd: Date?
    var nextRepeatStart: Date?

    init(id: String, content: String, memo: String, isAllDay: Bool, repeatStart: Date, repeatEnd: Date, repeatOption: String? = nil, repeatValue: String? = nil, category: Category? = nil, alarms: [Alarm], createdAt: Date?, updatedAt: Date? = nil, realRepeatStart: Date? = nil, realRepeatEnd: Date? = nil, prevRepeatEnd: Date? = nil, nextRepeatStart: Date? = nil) {
        self.id = id
        self.content = content
        self.memo = memo
        self.isAllDay = isAllDay
        self.repeatStart = repeatStart
        self.repeatEnd = repeatEnd
        self.repeatOption = repeatOption
        self.repeatValue = repeatValue
        self.category = category
        self.alarms = alarms
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.realRepeatStart = realRepeatStart
        self.realRepeatEnd = realRepeatEnd
        self.prevRepeatEnd = prevRepeatEnd
        self.nextRepeatStart = nextRepeatStart
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.memo = try container.decode(String.self, forKey: .memo)
        self.isAllDay = try container.decode(Bool.self, forKey: .isAllDay)
        self.repeatStart = try container.decode(Date.self, forKey: .repeatStart)
        self.repeatEnd = try container.decode(Date.self, forKey: .repeatEnd)
        self.repeatOption = try container.decodeIfPresent(String.self, forKey: .repeatOption)
        self.repeatValue = try container.decodeIfPresent(String.self, forKey: .repeatValue)
        self.category = try container.decodeIfPresent(Category.self, forKey: .category)
        self.alarms = try container.decode([Alarm].self, forKey: .alarms)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.realRepeatStart = try container.decodeIfPresent(Date.self, forKey: .realRepeatStart)
        self.realRepeatEnd = try container.decodeIfPresent(Date.self, forKey: .realRepeatEnd)
        self.prevRepeatEnd = try container.decodeIfPresent(Date.self, forKey: .prevRepeatEnd)
        self.nextRepeatStart = try container.decodeIfPresent(Date.self, forKey: .nextRepeatStart)

        let id = self.id
        let content = self.content
        let repeatStart = self.repeatStart
        if !alarms.isEmpty {
            Task {
                await AlarmHelper.createNotification(
                    identifier: id,
                    body: content,
                    date: repeatStart
                )
            }

            var repeatDate = repeatStart
            if repeatOption != nil {
                if let repeatValue,
                   repeatValue.hasPrefix("T")
                {
                    
                } else {
                    while repeatDate < .now {
                        do {
                            repeatDate = try nextRepeatStartDate(curRepeatStart: repeatDate)
                        } catch {
                            print("[Debug] \(error.localizedDescription) \(#fileID) \(#function)")
                        }
                    }

                    var count = 1
                    while count <= 30,
                          repeatDate <= repeatEnd
                    {
                        let date = repeatDate
                        Task {
                            await AlarmHelper.createNotification(
                                identifier: id,
                                body: content,
                                date: date
                            )
                        }

                        do {
                            repeatDate = try nextRepeatStartDate(curRepeatStart: repeatDate)
                            count += 1
                        } catch {
                            print("[Debug] \(error.localizedDescription) \(#fileID) \(#function)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - extension

extension Schedule {
    var at: RepeatAt {
        guard let repeatValue, let repeatOption else {
            return .none
        }

        var nextRepeatEnd: Date
        if repeatValue.first == "T" {
            let day = 60 * 60 * 24

            switch repeatOption {
            case "매주":
                nextRepeatEnd = repeatEnd.addingTimeInterval(TimeInterval(day * 7))
            case "격주":
                nextRepeatEnd = repeatEnd.addingTimeInterval(TimeInterval(day * 7 * 2))
            case "매달":
                nextRepeatEnd = CalendarHelper.nextMonthDate(curDate: repeatEnd)
            case "매년":
                nextRepeatEnd = CalendarHelper.nextYearDate(curDate: repeatEnd)
            default:
                return .none
            }
        } else {
            let calendar = Calendar.current
            var dateComponents: DateComponents

            dateComponents = calendar.dateComponents([.year, .month, .day], from: nextRepeatStart ?? repeatStart)
            dateComponents.hour = repeatEnd.hour
            dateComponents.minute = repeatEnd.minute

            nextRepeatEnd = calendar.date(from: dateComponents) ?? repeatEnd
        }

        if repeatEnd <= realRepeatEnd ?? CalendarHelper.getInfiniteDate(),
           realRepeatEnd ?? CalendarHelper.getInfiniteDate() < nextRepeatEnd
        {
            if realRepeatStart == repeatStart {
                return .none
            }

            return .back
        } else if realRepeatStart == repeatStart {
            return .front
        } else {
            return .middle
        }
    }
}

extension Schedule: Event, Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id && lhs.repeatStart == rhs.repeatStart
    }
}

extension Schedule {
    static func createRepeatSchedule(
        schedule: Schedule,
        repeatStart: Date,
        repeatEnd: Date,
        prevRepeatEnd: Date? = nil,
        nextRepeatStart: Date? = nil
    ) -> Schedule {
        var tmpPrevRepeatEnd: Date?

        if schedule.repeatOption != nil,
           let repeatValue = schedule.repeatValue
        {
            if repeatValue.hasPrefix("T") {
                tmpPrevRepeatEnd = prevRepeatEnd?.addingTimeInterval(
                    TimeInterval(
                        Double(
                            repeatValue.split(separator: "T")[0]
                        ) ?? 0
                    )
                )
            } else {
                tmpPrevRepeatEnd = schedule.repeatEnd
            }
        }

        return Schedule(
            id: schedule.id,
            content: schedule.content,
            memo: schedule.memo,
            isAllDay: schedule.isAllDay,
            repeatStart: repeatStart,
            repeatEnd: repeatEnd,
            repeatOption: schedule.repeatOption,
            repeatValue: schedule.repeatValue,
            category: schedule.category,
            alarms: schedule.alarms,
            createdAt: schedule.createdAt,
            realRepeatStart: schedule.repeatStart,
            realRepeatEnd: schedule.repeatEnd,
            prevRepeatEnd: tmpPrevRepeatEnd,
            nextRepeatStart: nextRepeatStart
        )
    }
}

extension Schedule {
    // curRepeatStart의 다음 repeatStart를 구하는 함수
    func nextRepeatStartDate(curRepeatStart: Date) throws -> Date {
        guard let repeatOption,
              let repeatValue
        else {
            throw RepeatError.invalid
        }

        let day = 60 * 60 * 24
        let calendar = Calendar.current

        let pattern = repeatValue.map { $0 == "1" ? true : false }

        var nextRepeatStart: Date = curRepeatStart.addingTimeInterval(TimeInterval(day))

        switch repeatOption {
        case RepeatOption.everyDay.rawValue:
            break

        case RepeatOption.everyWeek.rawValue:
            var index = (calendar.component(.weekday, from: curRepeatStart)) % 7
            while pattern[index] == false {
                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % 7
            }

        case RepeatOption.everySecondWeek.rawValue:
            var index = (calendar.component(.weekday, from: curRepeatStart)) % 7
            if index == 0 {
                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day * 7))
            }
            while pattern[index] == false {
                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % 7

                if index == 0 {
                    nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day * 7))
                }
            }

        case RepeatOption.everyMonth.rawValue:
            var index = nextRepeatStart.day - 1
            while pattern[index] == false {
                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                index = nextRepeatStart.day - 1
            }

        case RepeatOption.everyYear.rawValue:
            var index = curRepeatStart.month % 12
            nextRepeatStart = CalendarHelper.nextMonthDate(curDate: curRepeatStart)
            while pattern[index] == false {
                nextRepeatStart = CalendarHelper.nextMonthDate(curDate: nextRepeatStart)
                index = nextRepeatStart.month - 1
            }
        default:
            throw RepeatError.invalid
        }

        return nextRepeatStart
    }
}

extension Schedule {
    func prevRepeatEndDate(curRepeatEnd: Date) throws -> Date {
        guard let repeatOption,
              let repeatValue
        else {
            throw RepeatError.invalid
        }

        let day = 60 * 60 * 24
        let calendar = Calendar.current

        let pattern = repeatValue.map { $0 == "1" ? true : false }

        var prevRepeatEnd: Date = curRepeatEnd.addingTimeInterval(TimeInterval(-day))

        switch repeatOption {
        case RepeatOption.everyDay.rawValue:
            break

        case RepeatOption.everyWeek.rawValue:
            var index = (calendar.component(.weekday, from: curRepeatEnd) - 2)
            index = index < 0 ? 6 : index
            while pattern[index] == false {
                prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-day))
                if index - 1 < 0 {
                    index = 6
                } else {
                    index = index - 1
                }
            }

        case RepeatOption.everySecondWeek.rawValue:
            var index = (calendar.component(.weekday, from: curRepeatEnd) - 2)
            index = index < 0 ? 6 : index
            if index == 0 {
                prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-(day * 7)))
            }
            while pattern[index] == false {
                prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-day))
                if index - 1 < 0 {
                    index = 6
                } else {
                    index = index - 1
                }

                if index == 0 {
                    prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-(day * 7)))
                }
            }

        case RepeatOption.everyMonth.rawValue:
            var index = prevRepeatEnd.day - 1
            while pattern[index] == false {
                prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-day))
                index = prevRepeatEnd.day - 1
            }

        case RepeatOption.everyYear.rawValue:
            prevRepeatEnd = CalendarHelper.prevMonthDate(curDate: curRepeatEnd)
            var index = prevRepeatEnd.month - 1
            while pattern[index] == false {
                prevRepeatEnd = CalendarHelper.prevMonthDate(curDate: prevRepeatEnd)
                index = prevRepeatEnd.month - 1
            }

        default:
            throw RepeatError.invalid
        }

        return prevRepeatEnd
    }
}
