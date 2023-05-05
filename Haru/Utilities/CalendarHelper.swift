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

    class func getInfiniteDate() -> Date {
        let dateString = "2200-01-01T00:00:00.000Z"
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = Constants.dateFormat

        guard let date = dateFormatter.date(from: dateString) else { return Date() }
        return date
    }

    class func getDayofWeek(date: Date) -> Int {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: Date()) - 1
        return dayOfWeek
    }

    class func getClosestIdxDate(idx: Int, curDate: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = idx

        let closestDay = calendar.nextDate(after: curDate.addingTimeInterval(TimeInterval(-1)), matching: dateComponents, matchingPolicy: .nextTime)

        return closestDay
    }

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
}
