//
//  ScheduleService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

class ScheduleService {
    /**
     * 현재 선택된 달을 기준으로 이전 달, (선택된) 현재 달, 다음 달의 스케줄 데이터 가져오기
     */
    func fetchScheduleList(_ monthOffset: Int) -> [Schedule] {
        // api 호출
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return [
            Schedule(content: "5~8일 일정", memo: "", startTime: formatter.date(from: "2023/03/05 00:00")!, endTime: formatter.date(from: "2023/03/08 23:00")!),

            Schedule(content: "8~10일 일정", memo: "", startTime: formatter.date(from: "2023/03/08 00:00")!, endTime: formatter.date(from: "2023/03/10 01:00")!),

            Schedule(content: "9일 일정", memo: "", startTime: formatter.date(from: "2023/03/09 00:00")!, endTime: formatter.date(from: "2023/03/09 01:00")!),
            Schedule(content: "9~12일 일정", memo: "", startTime: formatter.date(from: "2023/03/09 00:10")!, endTime: formatter.date(from: "2023/03/12 23:59")!),
            Schedule(content: "9~13일 일정", memo: "", startTime: formatter.date(from: "2023/03/09 00:30")!, endTime: formatter.date(from: "2023/03/13 01:00")!),
        ]
    }

    func fittingScheduleList(_ dateList: [DateValue], monthOffset: Int) -> [[Int: Schedule]] {
        let scheduleList = fetchScheduleList(monthOffset)

        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 주차별 스케줄
        var weeksOfScheduleList = [[Schedule]](repeating: [], count: numberOfWeeks)

//        var result = [[(schedule: Schedule, order: Int)]](repeating: [], count: dateList.count) // row: 일별
        
        var result = [[Int: Schedule]](repeating: [:], count: dateList.count)

        var splitDateList = [[Date]]() // row: 주차, col: row주차에 있는 날짜들

        for row in 0 ..< numberOfWeeks {
            splitDateList.append([dateList[row*7 + 0].date, dateList[row*7 + 6].date])
        }

        for schedule in scheduleList {
            for (week, dates) in splitDateList.enumerated() {
                if schedule.endTime < dates[0] {
                    break
                }
                if schedule.startTime >= dates[1] {
                    continue
                }
                weeksOfScheduleList[week].append(schedule)
            }
        }

        for (week, weekOfSchedules) in weeksOfScheduleList.enumerated() {
            // 주 단위
            var orders = Array(repeating: Array(repeating: true, count: 5), count: 7)
            for schedule in weekOfSchedules {
                var order = 0
                var isFirst = true

                for (index, dateValue) in dateList[week*7 ..< (week + 1)*7].enumerated() {
                    if schedule.startTime < Calendar.current.date(byAdding: .day, value: 1, to: dateValue.date)!,
                       schedule.endTime > dateValue.date
                    {
                        if isFirst {
                            var i = 0
                            while i < 4, !orders[index][i] {
                                i += 1
                            }
                            order = i
                            orders[index][i] = false
                            isFirst = false
                        }
                        orders[index][order] = false
//                        result[week*7 + index].append((schedule, order))
                        result[week*7 + index][order] = schedule
                    }
                }
            }
        }

        return result
    }
}
