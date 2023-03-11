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
            Schedule(content: "3월 4일 일정", memo: "", startTime: formatter.date(from: "2023/03/04 00:00")!, endTime: formatter.date(from: "2023/03/04 23:00")!),
            Schedule(content: "3월 4일 일정", memo: "", startTime: formatter.date(from: "2023/03/04 00:00")!, endTime: formatter.date(from: "2023/03/04 23:00")!),
            Schedule(content: "3월 4일 일정", memo: "", startTime: formatter.date(from: "2023/03/04 00:00")!, endTime: formatter.date(from: "2023/03/04 23:00")!),
            
            Schedule(content: "3월 5일 일정", memo: "", startTime: formatter.date(from: "2023/03/05 00:00")!, endTime: formatter.date(from: "2023/03/05 23:00")!),
            Schedule(content: "3월 5일 일정", memo: "", startTime: formatter.date(from: "2023/03/05 00:00")!, endTime: formatter.date(from: "2023/03/05 23:00")!),
            Schedule(content: "3월 5일 일정", memo: "", startTime: formatter.date(from: "2023/03/05 00:00")!, endTime: formatter.date(from: "2023/03/05 23:00")!),
        ]
    }

    func fittingScheduleList(_ dateList: [DateValue], monthOffset: Int) -> [[Schedule]] {
        let scheduleList = fetchScheduleList(monthOffset)

        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)
        var result = [[Schedule]](repeating: [], count: numberOfWeeks)

        var splitDateList = [[Date]]()

        for row in 0 ..< numberOfWeeks {
            splitDateList.append([dateList[row*7+0].date, Calendar.current.date(byAdding: .day, value: 1, to: dateList[row*7+6].date)!])
        }

        for schedule in scheduleList {
            for (index, week) in splitDateList.enumerated() {
                if schedule.endTime < week[0] {
                    break
                }
                if schedule.startTime >= week[1] {
                    continue
                }
                result[index].append(schedule)
            }
        }

        return result
    }
}
