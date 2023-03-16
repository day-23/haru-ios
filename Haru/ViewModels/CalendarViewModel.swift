//
//  CalendarViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation
import SwiftUI

final class CalendarViewModel: ObservableObject {
    // 현재 달력에 보여질 일정들만 모은 자료구조
    @Published var scheduleList: [[Int: Schedule]] = [[:]]

    @Published var startOnSunday: Bool
    
    @Published var monthOffest: Int // 진짜 월과의 차이
    
    @Published var selectedDate: DateValue // 터치해서 선택된 날짜
    
    @Published var selectionSet: Set<DateValue> = [] // 드래그해서 선택된 날짜(들)

    @Published var dateList: [DateValue] = [] // 달력에 표시할 날짜들
    
    @Published var numberOfWeeks: Int = 0
    
    @Published var dayList: [String] = [] // 달력에 표시할 요일
    
    @Published var firstSelected: Bool = false
    var initIndex: Int = 0
    var startIndex: Int = 0
    var lastIndex: Int = 0
    
    
    @Published var categoryList: [Category] = []
    
    private let scheduleService = ScheduleService()
    private let categoryService = CategoryService()
    
    init() {
        startOnSunday = true
        monthOffest = 0
        selectedDate = .init(day: Date().day, date: Date())
        
        setStartOnSunday(startOnSunday)
        getCategoryList()
    }

    func addMonthOffset() {
        monthOffest += 1
        getCurDateList(monthOffest, startOnSunday)
    }

    func subMonthOffset() {
        monthOffest -= 1
        getCurDateList(monthOffest, startOnSunday)
    }
    
    func setStartOnSunday(_ startOnSunday: Bool) {
        self.startOnSunday = startOnSunday
        
        dayList = CalendarHelper.getDays(startOnSunday)
        
        getCurDateList(monthOffest, startOnSunday)
    }
    
    func getCurDateList(_ monthOffset: Int, _ startOnSunday: Bool) {
        dateList = CalendarHelper.extractDate(monthOffset, startOnSunday)
        
        numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)
        
        getCurMonthSchList(monthOffset, dateList)
    }

    func getCurMonthSchList(_ monthOffset: Int, _ dateList: [DateValue]) {
        scheduleList = [[Int: Schedule]](repeating: [:], count: dateList.count)
        scheduleService.fetchScheduleList(dateList[0].date, Calendar.current.date(byAdding: .day, value: 1, to: dateList.last!.date)!) { result in
            switch result {
            case .success(let success):
                self.scheduleList = self.scheduleService.fittingScheduleList(dateList, success)
            case .failure(let failure):
                print("[Debug] \(failure)")
            }
        }
    }
    
    func addSelectedItems(from value: DragGesture.Value, _ cellWidth: Double, _ cellHeight: Double) {
        let index = Int(value.location.y / cellHeight) * 7 + Int(value.location.x / cellWidth)
        var isRangeChanged = (true, true)
        
        if firstSelected {
            initIndex = index
            startIndex = index
            lastIndex = index
            firstSelected = false
            
            selectionSet.insert(dateList[initIndex])
        }
        
        if startIndex > index {
            startIndex = index
        } else if startIndex < index {
            for i in startIndex ..< min(initIndex, index) {
                selectionSet.remove(dateList[i])
            }
            startIndex = min(initIndex, index)
        } else {
            isRangeChanged.0 = false
        }
        
        if lastIndex < index {
            lastIndex = index
        } else if lastIndex > index {
            var i = max(initIndex, index) + 1
            while i <= lastIndex {
                selectionSet.remove(dateList[i])
                i += 1
            }
            lastIndex = max(initIndex, index)
        } else {
            isRangeChanged.1 = false
        }
        
        if isRangeChanged.0, isRangeChanged.1 {
            for i in startIndex ... lastIndex {
                selectionSet.insert(dateList[i])
            }
        }
    }
    
    func getCategoryList() {
        categoryService.fetchCategoryList { result in
            switch result {
            case .success(let success):
                self.categoryList = success
            case .failure(let failure):
                print("[Debug] \(failure)")
            }
        }
    }
}
