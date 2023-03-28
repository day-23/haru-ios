//
//  CalendarViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation
import SwiftUI

final class CalendarViewModel: ObservableObject {
    var productivityList: [[Int: [Productivity]]] = [[:]] // 원소 개수 == dateList의 개수
    @Published var viewProductivityList = [[[(Int, Productivity?)]]]() // 뷰에 보여주기 위한 일정 리스트
    
    @Published var scheduleList: [[Schedule]] = []
    @Published var todoList: [[Todo]] = []
    
    @Published var startOnSunday: Bool = true
    
    @Published var monthOffest: Int = 0 {
        didSet {
            getCurDateList(monthOffest, startOnSunday)
        }
    } // 진짜 월과의 차이
    
    @Published var pivotDate: Date = .init() // 터치해서 선택된 날짜
    
    @Published var selectionSet: Set<DateValue> = [] // 드래그해서 선택된 날짜(들)

    @Published var dateList: [DateValue] = [] // 달력에 표시할 날짜들
    
    @Published var numberOfWeeks: Int = 0 {
        didSet {
            maxOrder = numberOfWeeks < 6 ? 4 : 3
        }
    } // 달력에 표시된 주차
    var maxOrder: Int = 0
    
    @Published var dayList: [String] = [] // 달력에 표시할 요일
    
    @Published var firstSelected: Bool = false
    var initIndex: Int = 0
    var startIndex: Int = 0
    var lastIndex: Int = 0
    
    @Published var categoryList: [Category] = []
    
    @Published var allCategoryOff: Bool = false // 카테고리 달력에서 안보이게 하기
    @Published var allTodoOff: Bool = false // 할일 달력에서 안보이게 하기
    
    // MARK: - Service

    private let scheduleService = ScheduleService()
    private let categoryService = CategoryService()
    private let calendarService = CalendarService()
    
    init() {
        setStartOnSunday(startOnSunday)
        getCategoryList()
     
        print("calendarVM init")
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
        
        Task {
            let result = await calendarService.fetchScheduleAndTodo(dateList[0].date, Calendar.current.date(byAdding: .day, value: 1, to: dateList.last!.date)!)
            DispatchQueue.main.async {
                (self.productivityList, self.viewProductivityList) = self.fittingCalendar(dateList: dateList, scheduleList: result.0, todoList: result.1)
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
    
    // 선택된 날의 일정과 할일들 가져오기 (선택된 날짜로부터 15일 이전 ~ 15일 이후)
    func getSelectedScheduleList() {
        // TODO: currentDate @Published로 만들어주기
        scheduleList = [[Schedule]](repeating: [], count: 31)
        todoList = [[Todo]](repeating: [], count: 31)
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: -15, to: pivotDate) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: 15, to: pivotDate) else { return }
        
        Task {
            let (schList, todoList) = await calendarService.fetchScheduleAndTodo(startDate, endDate)
            
            DispatchQueue.main.async {
                (self.scheduleList, self.todoList) = self.fittingDay(startDate, endDate, scheduleList: schList, todoList: todoList)
            }
        }
    }
    
    // offSet만큼 더해주고 빼주깈
    func getMoreProductivityList(isRight: Bool) {
        // TODO: currentDate @Published로 만들어주기
        let offSet = 5
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: isRight ? 1 : -offSet, to: pivotDate) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: isRight ? offSet : -1, to: pivotDate) else { return }
        
        Task {
            let (schList, todoList) = await calendarService.fetchScheduleAndTodo(startDate, endDate)
            
            DispatchQueue.main.async {
                let result = self.fittingOffsetDay(startDate, endDate, scheduleList: schList, todoList: todoList)
                if isRight {
                    self.scheduleList.append(contentsOf: result.0)
                    self.scheduleList.removeFirst(5)
                    self.todoList.append(contentsOf: result.1)
                    self.todoList.removeFirst(5)
                } else {
                    self.scheduleList.insert(contentsOf: result.0, at: 0)
                    self.scheduleList.removeLast(5)
                    self.todoList.insert(contentsOf: result.1, at: 0)
                    self.todoList.removeLast(5)
                }
            }
        }
    }
    
    // MARK: - 캘린더 옵션에서 설정 가능한 카테고리 기능
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
    
    /**
     * 카테고리 추가하기
     */
    func addCategory(_ content: String, _ color: String?) {
        let category = Request.Category(content: content, color: color != nil ? "#" + color! : nil)
        
        self.categoryList.append(Category(id: UUID().uuidString, content: content, color: color, isSelected: true))
        let index = categoryList.endIndex - 1
        
        categoryService.addCategory(category) { result in
            switch result {
            case .success(let success):
                self.categoryList[index] = success
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    // MARK: - 달력에 보여주기 위한 fitting 함수들

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
        var result = [[Int: [Productivity]]](repeating: [:], count: dateList.count) // 날짜별

        var result_ = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: prodCnt), count: numberOfWeeks) // 순서

        if !allCategoryOff {
            fittingScheduleList(dateList, scheduleList, prodCnt, result: &result, result_: &result_)
        }
        if !allTodoOff {
            fittingTodoList(dateList, todoList, prodCnt, result: &result)
        }
        
        for week in 0 ..< numberOfWeeks {
            for order in 0 ..< prodCnt {
                var prev = result[week * 7 + 0][order]?.first
                var cnt = 1
                for day in 1 ..< 7 {
                    if let prev, let prod = result[week * 7 + day][order]?.first, prev.isEqualTo(prod) {
                        cnt += 1
                    } else {
                        result_[week][order].append((cnt, prev))
                        cnt = 1
                    }
                    prev = result[week * 7 + day][order]?.first
                }
                result_[week][order].append((cnt, prev))
            }
        }

        return (result, result_)
    }

    /**
     * 날짜별로 스케줄과 할일이 무엇이 있는지
     */
    func fittingDay(_ startDate: Date, _ endDate: Date, scheduleList: [Schedule], todoList: [Todo]) -> ([[Schedule]], [[Todo]]) {
        var result0 = [[Schedule]](repeating: [], count: 31)
        var result1 = [[Todo]](repeating: [], count: 31)

        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        var todoIdx = 0

        for (index, date) in stride(from: startDate, through: endDate, by: dayDurationInSeconds).enumerated() {
            // date에 해당하는 일정이 있는지 확인
            for sch in scheduleList {
                if sch.repeatStart < Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: date
                )!,
                    sch.repeatEnd >= date
                {
                    result0[index].append(sch)
                }
            }

            while todoIdx < todoList.count {
                if let endDate = todoList[todoIdx].endDate {
                    if date.isEqual(other: endDate) {
                        result1[index].append(todoList[todoIdx])
                        todoIdx += 1
                    } else if endDate < date {
                        todoIdx += 1
                    } else {
                        break
                    }
                } else {
                    todoIdx += 1
                }
            }
        }

        return (result0, result1)
    }

    func fittingOffsetDay(_ startDate: Date, _ endDate: Date, scheduleList: [Schedule], todoList: [Todo]) -> ([[Schedule]], [[Todo]]) {
        var result0 = [[Schedule]](repeating: [], count: 5)
        var result1 = [[Todo]](repeating: [], count: 5)

        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        var todoIdx = 0

        for (index, date) in stride(from: startDate, through: endDate, by: dayDurationInSeconds).enumerated() {
            // date에 해당하는 일정이 있는지 확인
            for sch in scheduleList {
                if sch.repeatStart < Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: date
                )!,
                    sch.repeatEnd >= date
                {
                    result0[index].append(sch)
                }
            }

            while todoIdx < todoList.count {
                if let endDate = todoList[todoIdx].endDate {
                    if date.isEqual(other: endDate) {
                        result1[index].append(todoList[todoIdx])
                        todoIdx += 1
                    } else {
                        break
                    }
                } else {
                    todoIdx += 1
                }
            }
        }

        return (result0, result1)
    }
    
    /**
     *  달력에 표시될 일정 만드는 함수
     */
    func fittingScheduleList(
        _ dateList: [DateValue],
        _ scheduleList: [Schedule],
        _ prodCnt: Int,
        result: inout [[Int: [Productivity]]],
        result_: inout [[[(Int, Productivity?)]]]
    ) {
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 주차별 스케줄
        var weeksOfScheduleList = [[Schedule]](repeating: [], count: numberOfWeeks)

        var splitDateList = [[Date]]() // row: 주차, col: row주차에 있는 날짜들

        for row in 0 ..< numberOfWeeks {
            splitDateList.append([dateList[row * 7 + 0].date, dateList[row * 7 + 6].date])
        }

        for schedule in scheduleList {
            // 카테고리 필터링
            if schedule.category == nil || schedule.category!.isSelected {
                for (week, dates) in splitDateList.enumerated() {
                    // 구간 필터링
                    if schedule.repeatEnd < dates[0] {
                        break
                    }
                    if schedule.repeatStart >= dates[1] {
                        continue
                    }
                    weeksOfScheduleList[week].append(schedule)
                }
            }
        }

        for (week, weekOfSchedules) in weeksOfScheduleList.enumerated() {
            // 주 단위
            var orders = Array(repeating: Array(repeating: true, count: prodCnt + 1), count: 7)
            for schedule in weekOfSchedules {
                var order = 0
                var isFirst = true

                for (index, dateValue) in dateList[week * 7 ..< (week + 1) * 7].enumerated() {
                    if schedule.repeatStart < Calendar.current.date(
                        byAdding: .day,
                        value: 1,
                        to: dateValue.date
                    )!,
                        schedule.repeatEnd >= dateValue.date
                    {
                        if isFirst {
                            var i = 0
                            while i < prodCnt, !orders[index][i] {
                                i += 1
                            }
                            order = i
                            orders[index][i] = false
                            isFirst = false
                        }
                        orders[index][order] = false
                        result[week * 7 + index][order] = (result[week * 7 + index][order] ?? []) + [schedule]
                    }
                }
            }
        }
    }
    
    func fittingTodoList(
        _ dateList: [DateValue],
        _ todoList: [Todo],
        _ prodCnt: Int,
        result: inout [[Int: [Productivity]]]
    ) {
        let todoList = todoList.filter { $0.endDate != nil }
        var todoIdx = 0, dateIdx = 0

        var maxKey = result[dateIdx].max { $0.key < $1.key }?.key ?? -1
        maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
        while todoIdx < todoList.count, dateIdx < dateList.count {
            if dateList[dateIdx].date.isEqual(other: todoList[todoIdx].endDate!) {
                result[dateIdx][maxKey] = (result[dateIdx][maxKey] ?? []) + [todoList[todoIdx]]
                maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
                todoIdx += 1
            } else if dateList[dateIdx].date > todoList[todoIdx].endDate! {
                todoIdx += 1
            } else {
                dateIdx += 1
                maxKey = result[dateIdx].max { $0.key < $1.key }?.key ?? -1
                maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
            }
        }
    }
}
