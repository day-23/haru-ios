//
//  CalendarViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation
import SwiftUI

final class CalendarViewModel: ObservableObject {
    @Published var scheduleList: [[Int: [Schedule]]] = [[:]] // 원소 개수 == dateList의 개수
    @Published var viewScheduleList = [[[(Int, Schedule?)]]]() // 뷰에 보여주기 위한 일정 리스트
    
    @Published var productivityList: [[Int: [Productivity]]] = [[:]] // 원소 개수 == dateList의 개수
    @Published var viewProductivityList = [[[(Int, Productivity?)]]]() // 뷰에 보여주기 위한 일정 리스트
    @Published var selectedProdList: [Productivity] = [] // 터치해서 선택된 날짜에 있는 리스트
    
    @Published var startOnSunday: Bool = true
    
    @Published var monthOffest: Int = 0 {
        didSet {
            getCurDateList(monthOffest, startOnSunday)
        }
    } // 진짜 월과의 차이
    
    @Published var selectedDate: DateValue // 터치해서 선택된 날짜
//    @Published var selectedScheduleList: [Schedule] = [] // 터치해서 선택된 날짜에 있는 일정 리스트
    
    
    @Published var selectionSet: Set<DateValue> = [] // 드래그해서 선택된 날짜(들)

    @Published var dateList: [DateValue] = [] // 달력에 표시할 날짜들
    
    @Published var numberOfWeeks: Int = 0 // 달력에 표시된 주차
    
    @Published var dayList: [String] = [] // 달력에 표시할 요일
    
    @Published var firstSelected: Bool = false
    var initIndex: Int = 0
    var startIndex: Int = 0
    var lastIndex: Int = 0
    
    @Published var categoryList: [Category] = []
    
    // MARK: - Service

    private let scheduleService = ScheduleService()
    private let categoryService = CategoryService()
    private let calendarService = CalendarService()
    
    init() {
        selectedDate = .init(day: Date().day, date: Date())
        
        setStartOnSunday(startOnSunday)
        getCategoryList()
     
        print("calendarVM init")
    }

    func setMonthOffset(_ offset: Int) {
        monthOffest = offset
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
        getCurMonthSchList(dateList)
    }

    func getCurMonthSchList(_ dateList: [DateValue]) {
        productivityList = [[Int: [Productivity]]](repeating: [:], count: dateList.count)
        viewProductivityList = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: 4), count: numberOfWeeks)
        
//        scheduleService.fetchScheduleList(dateList[0].date, Calendar.current.date(byAdding: .day, value: 1, to: dateList.last!.date)!) { result in
//            switch result {
//            case .success(let success):
//                (self.productivityList, self.viewProductivityList) = self.calendarService.fittingCalendar(dateList: dateList, scheduleList: success, todoList: [])
//            case .failure(let failure):
//                print("[Debug] \(failure) \(#fileID) \(#function)")
//            }
//        }
        
        Task {
            let result = await calendarService.fetchScheduleAndTodo(dateList[0].date, Calendar.current.date(byAdding: .day, value: 1, to: dateList.last!.date)!)
            DispatchQueue.main.async { [self] in
                (self.productivityList, self.viewProductivityList) = self.calendarService.fittingCalendar(dateList: dateList, scheduleList: result.0, todoList: result.1)
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
    
    // 선택된 날의 스케줄 가져오기
    func getSelectedScheduleList(_ selectedIndex: Int) {
        var result = [Productivity]()
        
        productivityList[selectedIndex].sorted { $0.key < $1.key }.forEach { key, value in
            result.append(contentsOf: value)
        }
        
        selectedProdList = result
    }
    
    // 카테고리 업데이트 (전체)
    func setAllCategoryList() {
        // TODO: 카테고리 수정시에 fittingSchedule 함수 호출하기 (코드가 꼬일 문제 있음)
        var categoryIds: [String] = []
        var isSelected: [Bool] = []
        
        categoryList.forEach { category in
            categoryIds.append(category.id)
            isSelected.append(category.isSelected)
        }
        
        categoryService.updateAllCategoyList(categoryIds: categoryIds, isSelected: isSelected) { result in
            switch result {
            case .success:
                self.getCategoryList()
                self.getCurMonthSchList(self.dateList)
            case .failure(let failure):
                print("[Debug] \(failure) \(#file) \(#fileID) \(#filePath)")
            }
        }
    }
}
