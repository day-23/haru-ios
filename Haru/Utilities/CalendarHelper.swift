//
//  CalendarHelper.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

// TODO: currentMonth가 Int 형인지 Date 형인지 구분할 수 있게 이름 짓기

class CalendarHelper {
    static let calendar = Calendar.current

    /**
     * 일주일의 요일을 표시해주기 위한 함수
     */
    class func getDays(_ startOnSunday: Bool) -> [String] {
        if startOnSunday {
            return ["일", "월", "화", "수", "목", "금", "토"]
        } else {
            return ["월", "화", "수", "목", "금", "토", "일"]
        }
    }

    /**
     * 보고 싶은 달의 Date를 리턴하는
     */
    class func getCurrentMonth(_ monthOffset: Int) -> Date {
        let calendar = Calendar.current

        // Getting Current Month Date ...
        guard let currentMonth = calendar.date(
            byAdding: .month,
            value: monthOffset,
            to: Date()
        ) else {
            return Date()
        }

        return currentMonth
    }

    /**
     * 연도와 월을 표시해주기 위한 함수
     * [연도, 월] 요소의 데이터 타입은 String
     */
    class func extraDate(_ monthOffset: Int) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY M"

        let date = formatter.string(from: getCurrentMonth(monthOffset))

        return date.components(separatedBy: " ")
    }

    /**
     * 달력에 날짜를 표시해주기 위한 함수
     * ex) [1,2,3,...31] 요소의 데이터 타입은 DateValue
     */
    class func extractDate(_ monthOffset: Int,
                           _ startOnSunday: Bool) -> [DateValue]
    {
        let calendar = Calendar
            .current // 현재 사용하고 있는 달력이 무엇인지 확인 (default: 그레고리)

        // Getting Current Month Date ...
        let currentMonth: Date = getCurrentMonth(monthOffset)

        var days: [DateValue] = currentMonth.getAllDates()
            .compactMap { date -> DateValue in
                // getting day ...
                let day = calendar.component(.day, from: date)
                return DateValue(day: day, date: date)
            }

        // adding offset days to get exact week day ...
        let firstWeekday = calendar.component(
            .weekday,
            from: days.first?.date ?? Date()
        )

        // 일주일의 시작 요일이 일요일인지 월요일인지에 따라 다르게 보여줌
        if startOnSunday {
            // TODO: 중복되는 코드가 있으므로 리팩토링 필요
            // 이전 달의 날짜를 보여줄 공간이 있다면 days에 추가
            for i in 1 ..< firstWeekday {
                guard let prevDate = calendar.date(
                    byAdding: .day,
                    value: -i,
                    to: currentMonth.startOfMonth()
                ) else {
                    break
                }
                days.insert(
                    DateValue(day: calendar.component(.day, from: prevDate),
                              date: prevDate, isPrevDate: true),
                    at: 0
                )
            }
            let totalCnt = Self.numberOfWeeksInMonth(days.count) * 7
            let offset = totalCnt - days.count + 1

            for i in 1 ..< offset {
                guard let nextDate = calendar.date(
                    byAdding: .day,
                    value: i,
                    to: currentMonth.endOfMonth()
                ) else {
                    break
                }
                days.append(DateValue(
                    day: calendar.component(.day, from: nextDate),
                    date: nextDate,
                    isNextDate: true
                ))
            }

        } else {
            // 이전 달의 날짜를 보여줄 공간이 있다면 days에 추가
            for i in stride(
                from: 1,
                to: firstWeekday - 1 == 0 ? 7 : firstWeekday - 1,
                by: 1
            ) {
                guard let prevDate = calendar.date(
                    byAdding: .day,
                    value: -i,
                    to: currentMonth.startOfMonth()
                ) else {
                    break
                }
                days.insert(
                    DateValue(day: calendar.component(.day, from: prevDate),
                              date: prevDate, isPrevDate: true),
                    at: 0
                )
            }

            let totalCnt = Self.numberOfWeeksInMonth(days.count) * 7
            let offset = totalCnt - days.count + 1

            for i in 1 ..< offset {
                guard let nextDate = calendar.date(
                    byAdding: .day,
                    value: i,
                    to: currentMonth.endOfMonth()
                ) else {
                    break
                }
                days.append(DateValue(
                    day: calendar.component(.day, from: nextDate),
                    date: nextDate,
                    isNextDate: true
                ))
            }
        }

        return days
    }

    class func numberOfWeeksInMonth(_ count: Int) -> Int {
        Int(ceil(Double(count) / 7))
    }

    class func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    class func removeTimeData(date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }

    class func getInfiniteDate(
        _ repeatEnd: Date? = nil
    ) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat

        if let repeatEnd {
            let repeatEndString = repeatEnd.description
            let tokens = repeatEndString.split(separator: " ")
            let dateString = "2200-01-01T\(tokens[1]).000Z"

            guard let date = dateFormatter.date(from: dateString) else { return Date() }
            return date
        } else {
            let dateString = "2200-01-01T00:00:00.000Z"

            guard let date = dateFormatter.date(from: dateString) else { return Date() }
            return date
        }
    }

    // 일: 1, 월:2 ...
    class func getDayofWeek(date: Date) -> Int {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        return dayOfWeek
    }

    class func getClosestIdxDate(idx: Int, curDate: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = idx

        let closestDay = calendar.nextDate(after: curDate.addingTimeInterval(TimeInterval(-1)), matching: dateComponents, matchingPolicy: .nextTime)

        return closestDay
    }

    // baseDate를 포함하여 가장 가까운 idx요일의 Date 구하기
    class func getClosestDayOfWeekDate(idx: Int, baseDate: Date) -> Date {
        let calendar = Calendar.current

        var result = calendar.date(bySetting: .weekday, value: idx, of: baseDate)!
        if result > baseDate {
            result = calendar.date(byAdding: .weekOfYear, value: -1, to: result)!
        }

        let nextResult = calendar.date(byAdding: .weekOfYear, value: 1, to: result)!
        let prevDiff = baseDate.timeIntervalSince(result)
        let nextDiff = nextResult.timeIntervalSince(baseDate)
        if nextDiff < prevDiff {
            result = nextResult
        }

        let baseWeek = calendar.dateComponents([.weekOfYear], from: baseDate)
        let resultDayWeek = calendar.dateComponents([.weekOfYear], from: result)
        if baseWeek.weekOfYear != resultDayWeek.weekOfYear {
            result = calendar.date(byAdding: .weekOfYear, value: -1, to: result)!
        }

        return result
    }

    // 반복 시작일과 반복 종료일 계산
    // startDate는 repeatStart의 hour, minute를 계산해서 넘긴다
    class func fittingStartEndDate(firstDate: Date, repeatStart: Date, lastDate: Date, repeatEnd: Date) -> (Date, Date) {
        var startDate = firstDate > repeatStart ? firstDate : repeatStart
        var endDate = lastDate > repeatEnd ? repeatEnd : lastDate

        // 제대로 된 repeatStart와 repeatEnd 만들기
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)

        // Set the hour and minute components
        dateComponents.hour = repeatStart.hour
        dateComponents.minute = repeatStart.minute

        startDate = calendar.date(from: dateComponents) ?? Date()

        dateComponents = calendar.dateComponents([.year, .month, .day], from: endDate)

        // Set the hour and minute components
        dateComponents.hour = repeatEnd.hour
        dateComponents.minute = repeatEnd.minute

        endDate = calendar.date(from: dateComponents) ?? Date()

        return (startDate, endDate)
    }

    class func numberOfDaysInMonth(date: Date) -> Int {
        let startDateComponents = DateComponents(year: date.year, month: date.month, day: 1)
        guard let startDate = calendar.date(from: startDateComponents) else {
            fatalError("Invalid date components")
        }

        // 해당 월의 마지막 날짜를 가져옵니다.
        guard let range = calendar.range(of: .day, in: .month, for: startDate) else {
            fatalError("Invalid date range")
        }

        return range.count
    }

    class func getDiffWeeks(date1: Date, date2: Date) -> Int {
        let calendar = Calendar.current
        let day = 60 * 60 * 24

        var date1 = date1
        var date2 = date2

        print(date1)
        print(date2)
        var dayOfWeek1 = calendar.component(.weekday, from: date1)
        while dayOfWeek1 > 1 {
            date1 = date1.addingTimeInterval(TimeInterval(-day))
            dayOfWeek1 -= 1
        }

        var dayOfWeek2 = calendar.component(.weekday, from: date2)
        while dayOfWeek2 > 1 {
            date2 = date2.addingTimeInterval(TimeInterval(-day))
            dayOfWeek2 -= 1
        }

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        print(components.day! / 7)
        return components.day! / 7
    }

    class func nextRepeatStartDate(
        curDate: Date,
        pattern: [Bool],
        repeatOption: RepeatOption
    ) -> Date {
        let day = 60 * 60 * 24
        let calendar = Calendar.current

        var nextRepeatStart: Date = curDate

        switch repeatOption {
        case .everyDay:
            break
        case .everyWeek:
            var index = (calendar.component(.weekday, from: curDate)) - 1
            while pattern[index] == false {
                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % 7
            }
        case .everySecondWeek:
            var index = (calendar.component(.weekday, from: curDate)) - 1
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
        case .everyMonth:
            var index = nextRepeatStart.day - 1
            while pattern[index] == false {
                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                index = nextRepeatStart.day - 1
            }
        case .everyYear:
            // TODO: 매년 repeat 처리해줘야함
            print("매년 처리해주세요")
        }

        return nextRepeatStart
    }

    // 현재 날짜의 다음 달 ex) 5/5 -> 6/5, 8/31 -> 10/31
    class func nextMonthDate(curDate: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var year = curDate.year
        var month = curDate.month
        while true {
            if month + 1 > 12 {
                month = 1
                year += 1
            } else {
                month += 1
            }
            var dateString = "\(year)-\(month)-\(curDate.day)"
            if let result = dateFormatter.date(from: dateString) {
                return result
            }
        }
    }
}
