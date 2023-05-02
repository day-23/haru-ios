//
//  CalendarHelper.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

// TODO: currentMonth가 Int 형인지 Date 형인지 구분할 수 있게 이름 짓기

class CalendarHelper {
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
        formatter.dateFormat = "YYYY MMMM"

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

    class func getInfiniteDate(repeatEnd: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: 2200, month: 1, day: 1)
        dateComponents.hour = repeatEnd.hour
        dateComponents.minute = repeatEnd.minute

        return calendar.date(from: dateComponents)!
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
}
