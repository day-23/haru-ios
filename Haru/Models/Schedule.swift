//
//  Schedule.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//  Updated by 최정민 on 2023/03/31.
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

    var alarms: [Alarm]

    // MARK: - Dates

    let createdAt: Date?
    var updatedAt: Date?

    // MARK: 반복 api를 위한 필드 (임의로 프론트에서 넣어주는 값들) 추후에 DTO를 새로 작성할 필요성 있음

    var realRepeatStart: Date?
    var realRepeatEnd: Date?

    var prevRepeatEnd: Date?
    var nextRepeatStart: Date?
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

extension Schedule: Productivity, Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id && lhs.repeatStart == rhs.repeatStart
    }
}

extension Schedule {
    static func createRepeatSchedule(
        schedule: Schedule, // 원본 스케줄
        repeatStart: Date,
        repeatEnd: Date,
        prevRepeatEnd: Date? = nil,
        nextRepeatStart: Date? = nil
    ) -> Schedule {
        var realPrevRepeatEnd: Date?

        if schedule.repeatOption != nil,
           let repeatValue = schedule.repeatValue
        {
            if repeatValue.hasPrefix("T") {
                realPrevRepeatEnd = prevRepeatEnd?.addingTimeInterval(
                    TimeInterval(
                        Double(
                            repeatValue.split(separator: "T")[0]
                        ) ?? 0
                    )
                )
            } else {
                realPrevRepeatEnd = prevRepeatEnd
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
            prevRepeatEnd: realPrevRepeatEnd,
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

extension Schedule {
    func nextSucRepeatStartDate(curRepeatStart: Date) throws -> Date {
        guard let repeatOption
        else {
            throw RepeatError.invalid
        }

        let calendar = Calendar.current
        var dateComponents: DateComponents
        let day = 60 * 60 * 24

        var pivotDate = curRepeatStart

        switch repeatOption {
        case RepeatOption.everyDay.rawValue:
            throw RepeatError.invalid

        case RepeatOption.everyWeek.rawValue:
            let result = pivotDate.addingTimeInterval(TimeInterval(day * 7))
            dateComponents = calendar.dateComponents([.year, .month, .day], from: result)
            dateComponents.hour = self.repeatStart.hour
            dateComponents.minute = self.repeatStart.minute
            dateComponents.second = self.repeatStart.second

            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(id)에 문제가 있습니다. \(#fileID) \(#function)")
                throw RepeatError.calculation
            }

            return repeatStart

        case RepeatOption.everySecondWeek.rawValue:
            let result = pivotDate.addingTimeInterval(TimeInterval(day * 7 * 2))
            dateComponents = calendar.dateComponents([.year, .month, .day], from: result)
            dateComponents.hour = self.repeatStart.hour
            dateComponents.minute = self.repeatStart.minute
            dateComponents.second = self.repeatStart.second

            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(id)에 문제가 있습니다. \(#fileID) \(#function)")
                throw RepeatError.calculation
            }

            return repeatStart
        case RepeatOption.everyMonth.rawValue:
            return CalendarHelper.nextMonthDate(curDate: pivotDate)

        case RepeatOption.everyYear.rawValue:
            return CalendarHelper.nextYearDate(curDate: pivotDate)
        default:
            throw RepeatError.invalid
        }
    }
}
