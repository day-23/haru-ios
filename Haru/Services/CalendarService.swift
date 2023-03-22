//
//  CalendarService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/22.
//

import Alamofire
import Foundation

final class CalendarService {
    private var scheduleService: ScheduleService = .init()

    /**
     * 달력에 보여질 일정과 할일 만드는 함수
     */
    func fittingCalendar(
        dateList: [DateValue],
        scheduleList: [Schedule],
        todoList: [Todo]
    ) -> ([[Int: [Productivity]]], [[[(Int, Productivity?)]]]) {
        // 주차 개수
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 최대 보여줄 수 있는 일정, 할일 개수
        let prodCnt = numberOfWeeks < 6 ? 4 : 3

        // 최종 결과
        var result = [[Int: [Productivity]]](repeating: [:], count: dateList.count)

        var result_ = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: prodCnt), count: numberOfWeeks)

        scheduleService.fittingScheduleList(dateList, scheduleList, prodCnt, result: &result, result_: &result_)

        return (result, result_)
    }
}
