//
//  CalendarViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    // 현재 달력에 보여질 일정들만 모은 자료구조
    @Published var scheduleList: [[Schedule]] = []

    @Published var startOnSunday: Bool
    
    @Published var monthOffest: Int // 진짜 월과의 차이
    
    @Published var selectedDate: DateValue  // 터치해서 선택된 날짜
    
    @Published var selectionSet: Set<DateValue> = []    // 드래그해서 선택된 날짜(들)

    @Published var dateList: [DateValue] = []   // 달력에 표시할 날짜들
    
    var dayList: [String] = []    // 달력에 표시할 요일
    
    private let scheduleService = ScheduleService()
    init(dateList: [DateValue]) {
        startOnSunday = true
        monthOffest = 0
        selectedDate = .init(day: Date().day, date: Date())
        
        setStartOnSunday(startOnSunday)
        getCurDateList(monthOffest, startOnSunday)
        getCurMonthSchList(0, dateList)
    }
    
    func setStartOnSunday(_ startOnSunday: Bool) {
        self.startOnSunday = startOnSunday
        dayList = CalendarHelper.getDays(startOnSunday)
    }

    func getCurDateList(_ monthOffset: Int, _ startOnSunday: Bool) {
        self.dateList = CalendarHelper.extractDate(monthOffset, startOnSunday)
    }

    func getCurMonthSchList(_ currentMonth: Int, _ dateList: [DateValue]) {
        self.scheduleList = self.scheduleService.fittingScheduleList(dateList, currentMonth: currentMonth)
    }
}
