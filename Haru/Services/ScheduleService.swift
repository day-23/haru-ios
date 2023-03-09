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
    func fetchScheduleList(_ currentMonth: Int) -> [Schedule] {
        // api 호출
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return [
            Schedule(content: "2월 23일 ~ 2월 25일 일정", memo: "", startTime: formatter.date(from: "2023/02/23 21:00")!, endTime: formatter.date(from: "2023/02/25 22:00")!),
            Schedule(content: "2월 24일 ~ 2월 28일 일정", memo: "", startTime: formatter.date(from: "2023/02/24 21:00")!, endTime: formatter.date(from: "2023/02/28 22:00")!),
            Schedule(content: "2월 27일 ~ 3월 02일 일정", memo: "", startTime: formatter.date(from: "2023/02/27 21:00")!, endTime: formatter.date(from: "2023/03/02 22:00")!),
            Schedule(content: "3월 7일 일정", memo: "", startTime: formatter.date(from: "2023/03/07 21:00")!, endTime: formatter.date(from: "2023/03/07 22:00")!),
            Schedule(content: "3월 7일 ~ 3월 10일 일정", memo: "", startTime: formatter.date(from: "2023/03/07 12:00")!, endTime: formatter.date(from: "2023/03/10 13:00")!),
            Schedule(content: "3월 11일 일정", memo: "", startTime: formatter.date(from: "2023/03/11 12:00")!, endTime: formatter.date(from: "2023/03/11 13:00")!),
            Schedule(content: "3월 11일 일정", memo: "", startTime: formatter.date(from: "2023/03/11 12:00")!, endTime: formatter.date(from: "2023/03/11 13:00")!),
            Schedule(content: "3월 11일 일정", memo: "", startTime: formatter.date(from: "2023/03/11 12:00")!, endTime: formatter.date(from: "2023/03/11 13:00")!),
            Schedule(content: "3월 11일 일정", memo: "", startTime: formatter.date(from: "2023/03/11 12:00")!, endTime: formatter.date(from: "2023/03/11 13:00")!),
            Schedule(content: "3월 9일 ~ 3월 14일 일정", memo: "", startTime: formatter.date(from: "2023/03/09 20:00")!, endTime: formatter.date(from: "2023/03/14 22:00")!),
            Schedule(content: "3월 10일 ~ 3월 15일 일정", memo: "", startTime: formatter.date(from: "2023/03/10 10:00")!, endTime: formatter.date(from: "2023/03/15 16:00")!),
            Schedule(content: "3월 11일 ~ 3월 15일 일정", memo: "", startTime: formatter.date(from: "2023/03/11 10:00")!, endTime: formatter.date(from: "2023/03/15 16:00")!),
            Schedule(content: "3월 16일 일정", memo: "", startTime: formatter.date(from: "2023/03/16 13:30")!, endTime: formatter.date(from: "2023/03/16 18:00")!),
            Schedule(content: "3월 30일 ~ 4월 3일 일정", memo: "", startTime: formatter.date(from: "2023/03/30 00:00")!, endTime: formatter.date(from: "2023/04/03 23:59")!),
            Schedule(content: "4월 5일 일정", memo: "", startTime: formatter.date(from: "2023/04/05 00:00")!, endTime: formatter.date(from: "2023/04/05 23:59")!),
            Schedule(content: "4월 6일 일정", memo: "", startTime: formatter.date(from: "2023/04/06 00:00")!, endTime: formatter.date(from: "2023/04/06 23:59")!),
            Schedule(content: "4월 6일 일정", memo: "", startTime: formatter.date(from: "2023/04/06 00:00")!, endTime: formatter.date(from: "2023/04/06 23:59")!),
            Schedule(content: "4월 6일 일정", memo: "", startTime: formatter.date(from: "2023/04/06 00:00")!, endTime: formatter.date(from: "2023/04/06 23:59")!),
            Schedule(content: "4월 6일 일정", memo: "", startTime: formatter.date(from: "2023/04/06 00:00")!, endTime: formatter.date(from: "2023/04/06 23:59")!),
            Schedule(content: "4월 6일 일정", memo: "", startTime: formatter.date(from: "2023/04/06 00:00")!, endTime: formatter.date(from: "2023/04/06 23:59")!),
        ]
    }

    func fittingScheduleList(_ dateList: [DateValue], currentMonth: Int) -> [[Schedule]] {
        let scheduleList = fetchScheduleList(currentMonth)

        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)
        var result = [[Schedule]](repeating: [], count: numberOfWeeks)

        var splitDateList = [[Date]]()

        for row in 0 ..< numberOfWeeks {
            splitDateList.append([dateList[row*7+0].date, dateList[row*7+6].date])
        }

        for schedule in scheduleList {
            for (index, week) in splitDateList.enumerated() {
                if (schedule.endTime < week[0]) {
                    break
                }
                if(schedule.startTime > week[1]) {
                    continue
                }
                result[index].append(schedule)
            }
        }

        return result
    }
}
