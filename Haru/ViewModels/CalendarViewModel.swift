//
//  CalendarViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation
import SwiftUI

final class CalendarViewModel: ObservableObject {
    var productivityList: [[Int: [Event]]] = [[:]] // 원소 개수 == dateList의 개수
    @Published var viewProductivityList = [[[(Int, Event?)]]]() // 뷰에 보여주기 위한 일정 리스트
    
    // MARK: - DetailView에 보여질 데이터들

    @Published var scheduleList: [[Schedule]] = []
    @Published var todoList: [[Todo]] = []
    @Published var pivotDateList: [Date] = Array(repeating: .now, count: 31)

    @Published var pivotDate: Date = .init()
    
    @Published var startOnSunday: Bool = true
    
    @Published var monthOffest: Int = 0 {
        didSet {
            getCurDateList(monthOffest, startOnSunday)
        }
    } // 진짜 월과의 차이
    
    @Published var curDate: Date = .init() {
        didSet {
            setMonthOffSet(offset: (curDate.year - Date().year) * 12 + curDate.month - Date().month)
        }
    }
    
    @Published var selectionSet: Set<DateValue> = [] // 드래그해서 선택된 날짜(들)

    @Published var dateList: [DateValue] = [] // 달력에 표시할 날짜들
    
    @Published var numberOfWeeks: Int = 0 // 달력에 표시된 주차
    
    var maxOrder: Int = 0
    
    @Published var dayList: [String] = [] // 달력에 표시할 요일
    
    @Published var firstSelected: Bool = false
    var initIndex: Int = 0
    var startIndex: Int = 0
    var lastIndex: Int = 0
    
    // MARK: - 카테고리

    @Published var isUnknownCategorySelected: Bool = true
    @Published var isHolidayCategorySelected: Bool = true
    
    var unknownCategory = Category(
        id: UUID().uuidString,
        content: "미분류",
        isSelected: true
    )
    var holidayCategory = Global.shared.holidayCategory
    
    @Published var categoryList: [Category] = []
    
    @Published var allCategoryOff: Bool = false // 카테고리 달력에서 안보이게 하기
    
    @Published var allTodoOff: Bool = false // 할일 달력에서 안보이게 하기
    @Published var nonCompTodoOff: Bool = false // 미완료 할일 달력에서 안보이게 하기
    @Published var compTodoOff: Bool = false // 완료 할일 달력에서 안보이게 하기
    
    var allOff: Bool {
        allCategoryOff && allTodoOff
    }
    
    func setStartOnSunday(_ startOnSunday: Bool) {
        self.startOnSunday = startOnSunday
        
        dayList = CalendarHelper.getDays(startOnSunday)
        getCategoryList()
        getCurDateList(monthOffest, startOnSunday)
    }
    
    func setMonthOffSet(offset: Int) {
        monthOffest = offset
    }
    
    func getCurDateList(_ monthOffset: Int, _ startOnSunday: Bool) {
        dateList = CalendarHelper.extractDate(monthOffset, startOnSunday)
        
        let nOW = CalendarHelper.numberOfWeeksInMonth(dateList.count)
        let deviceSize = UIScreen.main.bounds.size
        if deviceSize.height < 800 {
            maxOrder = nOW < 6 ? 2 : 1
        } else if deviceSize.height < 920 {
            maxOrder = nOW < 6 ? 3 : 2
        } else {
            maxOrder = nOW < 6 ? 4 : 3
        }
        getCurMonthSchList(dateList)
        numberOfWeeks = nOW
    }

    // MARK: 달력에 해당하는 월에 맞는 스케줄 + 할일 표시해주기 위한 함수

    func getCurMonthSchList(_ dateList: [DateValue]) {
        productivityList = [[Int: [Event]]](repeating: [:], count: dateList.count)
        viewProductivityList = [[[(Int, Event?)]]](repeating: [[(Int, Event?)]](repeating: [], count: maxOrder), count: CalendarHelper.numberOfWeeksInMonth(dateList.count))
        
        guard let firstDate = dateList.first?.date, let startDate = Calendar.current.date(byAdding: .day, value: -1, to: firstDate) else { return }
        guard let lastDate = dateList.last?.date, let endDate = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) else { return }
        
        ScheduleService.fetchScheduleAndTodo(startDate, endDate) { result in
            switch result {
            case .success(let success):
                var beforeRepeat = success
                var repeatScheduleList = [Schedule]()
                var repeatTodoList = [Todo]()
                var idx = 0
                // 반복 일정을 만들면서 중복 제거를 위함
                while idx < beforeRepeat.0.count {
                    let sch = beforeRepeat.0[idx]
                    if sch.repeatValue != nil {
                        repeatScheduleList.append(sch)
                        beforeRepeat.0.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                idx = 0
                while idx < beforeRepeat.1.count {
                    let todo = beforeRepeat.1[idx]
                    if todo.repeatValue != nil {
                        repeatTodoList.append(todo)
                        beforeRepeat.1.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                    
                beforeRepeat.0.append(contentsOf: self.makeRepeatSchedule(firstDate: firstDate, curDate: dateList[10].date, lastDate: lastDate, repeatScheduleList: repeatScheduleList))
                beforeRepeat.1.append(contentsOf: self.makeRepeatTodo(firstDate: firstDate, lastDate: lastDate, repeatTodoList: repeatTodoList))
                
                let result = (beforeRepeat.0.sorted {
                    $0.repeatStart < $1.repeatStart
                }, beforeRepeat.1.sorted {
                    guard let leftEndDate = $0.endDate, let rightEndDate = $1.endDate else {
                        print("[Error] (일정 + 투두) 가져오는 api에는 endDate가 null이 아닌 todo만 있어야합니다. \(#fileID) \(#function)")
                        return false
                    }
                    return leftEndDate < rightEndDate
                })
                
                (self.productivityList, self.viewProductivityList) = self.fittingCalendar(dateList: dateList, scheduleList: result.0, todoList: result.1)
                
            case .failure(let failure):
                print("[Error] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    // 드래그해서 선택한 날짜를 위한 로직
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
        CategoryService.fetchCategoryList { result in
            switch result {
            case .success(let success):
                self.unknownCategory.isSelected = self.isUnknownCategorySelected
                self.holidayCategory.isSelected = self.isHolidayCategorySelected
                self.categoryList = [self.unknownCategory] + success + [self.holidayCategory]
            case .failure(let failure):
                print("[Debug] \(failure)")
            }
        }
    }
    
    // 선택된 날의 일정과 할일들 가져오기 (선택된 날짜로부터 15일 이전 ~ 15일 이후)
    func getSelectedScheduleList() {
        scheduleList = [[Schedule]](repeating: [], count: 31)
        todoList = [[Todo]](repeating: [], count: 31)
        pivotDateList = [Date](repeating: Date(), count: 31)
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: -15, to: pivotDate) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: 15, to: pivotDate) else { return }
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for (index, date) in stride(from: startDate, through: endDate, by: dayDurationInSeconds).enumerated() {
            pivotDateList[index] = date
        }
        
        ScheduleService.fetchScheduleAndTodo(startDate, endDate) { result in
            switch result {
            case .success(let success):
                var beforeRepeat = success
                // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
                var repeatScheduleList = [Schedule]()
                var repeatTodoList = [Todo]()
                var idx = 0
                while idx < beforeRepeat.0.count {
                    let sch = beforeRepeat.0[idx]
                    if sch.repeatValue != nil {
                        repeatScheduleList.append(sch)
                        beforeRepeat.0.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                idx = 0
                while idx < beforeRepeat.1.count {
                    let todo = beforeRepeat.1[idx]
                    if todo.repeatValue != nil {
                        repeatTodoList.append(todo)
                        beforeRepeat.1.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                    
                beforeRepeat.0.append(contentsOf: self.makeRepeatSchedule(firstDate: startDate, curDate: self.pivotDateList[15], lastDate: endDate, repeatScheduleList: repeatScheduleList))
                beforeRepeat.1.append(contentsOf: self.makeRepeatTodo(firstDate: startDate, lastDate: endDate, repeatTodoList: repeatTodoList))
                
                let result = (beforeRepeat.0.sorted {
                    $0.repeatStart < $1.repeatStart
                }, beforeRepeat.1.sorted {
                    guard let leftEndDate = $0.endDate, let rightEndDate = $1.endDate else {
                        print("[Error] (일정 + 투두) 가져오는 api에는 endDate가 null이 아닌 todo만 있어야합니다. \(#fileID) \(#function)")
                        return false
                    }
                    return leftEndDate < rightEndDate
                })
                
                (self.scheduleList, self.todoList) = self.fittingDay(startDate, endDate, scheduleList: result.0, todoList: result.1)
                
            case .failure(let failure):
                print("[Error] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    // 수정 및 저장과 같은 이벤트가 있을 때 새로고침을 위한 함수
    func getRefreshProductivityList() {
        guard let startDate = pivotDateList.first else { return }
        guard let endDate = pivotDateList.last else { return }
    
        var tempPivotDateList = [Date](repeating: Date(), count: 31)
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for (index, date) in stride(from: startDate, through: endDate, by: dayDurationInSeconds).enumerated() {
            tempPivotDateList[index] = date
        }
        
        ScheduleService.fetchScheduleAndTodo(startDate, endDate) { result in
            switch result {
            case .success(let success):
                var beforeRepeat = success
                // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
                var repeatScheduleList = [Schedule]()
                var repeatTodoList = [Todo]()
                var idx = 0
                while idx < beforeRepeat.0.count {
                    let sch = beforeRepeat.0[idx]
                    if sch.repeatValue != nil {
                        repeatScheduleList.append(sch)
                        beforeRepeat.0.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                idx = 0
                while idx < beforeRepeat.1.count {
                    let todo = beforeRepeat.1[idx]
                    if todo.repeatValue != nil {
                        repeatTodoList.append(todo)
                        beforeRepeat.1.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                    
                beforeRepeat.0.append(contentsOf: self.makeRepeatSchedule(firstDate: startDate, curDate: self.pivotDateList[15], lastDate: endDate, repeatScheduleList: repeatScheduleList))
                beforeRepeat.1.append(contentsOf: self.makeRepeatTodo(firstDate: startDate, lastDate: endDate, repeatTodoList: repeatTodoList))
                
                let result = (beforeRepeat.0.sorted {
                    $0.repeatStart < $1.repeatStart
                }, beforeRepeat.1.sorted {
                    guard let leftEndDate = $0.endDate, let rightEndDate = $1.endDate else {
                        print("[Error] (일정 + 투두) 가져오는 api에는 endDate가 null이 아닌 todo만 있어야합니다. \(#fileID) \(#function)")
                        return false
                    }
                    return leftEndDate < rightEndDate
                })
                
                self.pivotDateList = tempPivotDateList
                (self.scheduleList, self.todoList) = self.fittingDay(startDate, endDate, scheduleList: result.0, todoList: result.1)
                
            case .failure(let failure):
                print("[Error] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    // offSet만큼 더해주고 빼주기
    func getMoreProductivityList(isRight: Bool, offSet: Int, completion: @escaping () -> Void) {
        guard let toDate = isRight ? pivotDateList.last : pivotDateList.first else { return }
        let startValue = isRight ? 1 : -offSet
        let endValue = isRight ? offSet : -1
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: startValue, to: toDate) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: endValue, to: toDate) else { return }
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24

        ScheduleService.fetchScheduleAndTodo(startDate, endDate) { result in
            switch result {
            case .success(let success):
                var beforeRepeat = success
                // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
                var repeatScheduleList = [Schedule]()
                var repeatTodoList = [Todo]()
                var idx = 0
                while idx < beforeRepeat.0.count {
                    let sch = beforeRepeat.0[idx]
                    if sch.repeatValue != nil {
                        repeatScheduleList.append(sch)
                        beforeRepeat.0.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                idx = 0
                while idx < beforeRepeat.1.count {
                    let todo = beforeRepeat.1[idx]
                    if todo.repeatValue != nil {
                        repeatTodoList.append(todo)
                        beforeRepeat.1.remove(at: idx)
                    } else {
                        idx += 1
                    }
                }
                    
                beforeRepeat.0.append(contentsOf: self.makeRepeatSchedule(firstDate: startDate, curDate: startDate, lastDate: endDate, repeatScheduleList: repeatScheduleList))
                beforeRepeat.1.append(contentsOf: self.makeRepeatTodo(firstDate: startDate, lastDate: endDate, repeatTodoList: repeatTodoList))
                
                let result = (beforeRepeat.0.sorted {
                    $0.repeatStart < $1.repeatStart
                }, beforeRepeat.1.sorted {
                    guard let leftEndDate = $0.endDate, let rightEndDate = $1.endDate else {
                        print("[Error] (일정 + 투두) 가져오는 api에는 endDate가 null이 아닌 todo만 있어야합니다. \(#fileID) \(#function)")
                        return false
                    }
                    return leftEndDate < rightEndDate
                })
                
                let prodList = self.fittingOffsetDay(startDate, endDate, scheduleList: result.0, todoList: result.1)
                
                var addedDateList = [Date]()
                addedDateList.append(contentsOf: stride(from: startDate, through: endDate, by: dayDurationInSeconds))
                    
                if isRight {
                    self.pivotDateList.append(contentsOf: addedDateList)
                    self.pivotDateList.removeFirst(5)
                    self.scheduleList.append(contentsOf: prodList.0)
                    self.scheduleList.removeFirst(5)
                    self.todoList.append(contentsOf: prodList.1)
                    self.todoList.removeFirst(5)
                        
                } else {
                    self.pivotDateList.insert(contentsOf: addedDateList, at: 0)
                    self.pivotDateList.removeLast(5)
                    self.scheduleList.insert(contentsOf: prodList.0, at: 0)
                    self.scheduleList.removeLast(5)
                    self.todoList.insert(contentsOf: prodList.1, at: 0)
                    self.todoList.removeLast(5)
                }
                completion()
                
            case .failure(let failure):
                print("[Error] \(failure) \(#fileID) \(#function)")
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
        
        CategoryService.updateAllCategoyList(categoryIds: categoryIds, isSelected: isSelected) { result in
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
    func addCategory(_ content: String, _ color: String?, completion: @escaping () -> Void) {
        let category = Request.Category(content: content, color: color != nil ? "#" + color! : nil)
        
        categoryList.append(Category(id: UUID().uuidString, content: content, color: color, isSelected: true))
        let index = categoryList.endIndex - 1
        
        CategoryService.addCategory(category) { result in
            switch result {
            case .success(let success):
                self.categoryList[index] = success
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func updateCategory(
        categoryId: String,
        content: String,
        color: String?,
        completion: @escaping () -> Void
    ) {
        let category = Request.Category(content: content, color: color)
        
        CategoryService.updateCategory(categoryId: categoryId, category: category) { result in
            switch result {
            case .success:
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func deleteCategory(
        categoryId: String,
        completion: @escaping () -> Void
    ) {
        CategoryService.deleteCategory(categoryId: categoryId) { result in
            switch result {
            case .success:
                completion()
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
    ) -> ([[Int: [Event]]], [[[(Int, Event?)]]]) {
        // 주차 개수
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 최대 보여줄 수 있는 일정, 할일 개수
        let prodCnt = maxOrder

        // 최종 결과
        var result = [[Int: [Event]]](repeating: [:], count: dateList.count) // 날짜별

        var result_ = [[[(Int, Event?)]]](repeating: [[(Int, Event?)]](repeating: [], count: prodCnt), count: numberOfWeeks) // 달력에 보여질 결과물

        if !allCategoryOff {
            fittingScheduleList(dateList, scheduleList, prodCnt, result: &result)
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

        var todoIdx = 0
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24

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
        result: inout [[Int: [Event]]]
    ) {
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 주차별 스케줄
        var weeksOfScheduleList = [[Schedule]](repeating: [], count: numberOfWeeks)

        var splitDateList = [[Date]]() // row: 주차, col: row주차에 있는 날짜들

        for row in 0 ..< numberOfWeeks {
            splitDateList.append([dateList[row * 7 + 0].date, Calendar.current.date(byAdding: .day, value: 1, to: dateList[row * 7 + 6].date) ?? dateList[row * 7 + 6].date])
        }

        for schedule in scheduleList {
            // 카테고리 필터링
            if schedule.category == nil, !isUnknownCategorySelected { continue }
            if schedule.category == Global.shared.holidayCategory, !isHolidayCategorySelected { continue }
            if let category = schedule.category, !category.isSelected {
                continue
            }
            
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
                        if isFirst || order == prodCnt {
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
        result: inout [[Int: [Event]]]
    ) {
        let todoList = todoList.filter {
            $0.endDate != nil &&
                ($0.completed == true ? !compTodoOff : !nonCompTodoOff)
        }
        var todoIdx = 0, dateIdx = 0

        var maxKey: Int
        while todoIdx < todoList.count, dateIdx < dateList.count {
            if dateList[dateIdx].date.isEqual(other: todoList[todoIdx].endDate!) {
                maxKey = result[dateIdx].keys.max(by: <) ?? -1
                maxKey = maxKey >= prodCnt ? prodCnt : maxKey + 1
                result[dateIdx][maxKey] = (result[dateIdx][maxKey] ?? []) + [todoList[todoIdx]]
                todoIdx += 1
            } else if dateList[dateIdx].date > todoList[todoIdx].endDate! {
                todoIdx += 1
            } else {
                dateIdx += 1
            }
        }
    }
    
    // MARK: - 반복 일정 만들어주기

    /**
     * 반복인 일정들만 repeatSchList에 받아와서 반복 (일정)데이터 만들어서 리턴
     */
    func makeRepeatSchedule(
        firstDate: Date,
        curDate: Date,
        lastDate: Date,
        repeatScheduleList: [Schedule]
    ) -> [Schedule] {
        var result = [Schedule]()
        for sch in repeatScheduleList {
            guard let repeatValue = sch.repeatValue else {
                print("[Error] schedule id: \(sch.id) 반복 일정은 repeatValue가 null이면 안됩니다. \(#fileID) \(#function)")
                continue
            }
            if repeatValue.first == "T" {
                result.append(contentsOf: successionRepeatSchedule(firstDate: firstDate, curDate: curDate, lastDate: lastDate, oriRepeatSch: sch))
            } else {
                result.append(contentsOf: singleRepeatSchedule(firstDate: firstDate, lastDate: lastDate, oriRepeatSch: sch))
            }
        }
        return result
    }

    // 하루치 일정의 반복 (repeatValue: 0,1)
    func singleRepeatSchedule(firstDate: Date, lastDate: Date, oriRepeatSch: Schedule) -> [Schedule] {
        switch oriRepeatSch.repeatOption {
        case .everyDay:
            return repeatEveryDay(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch)
        case .everyWeek:
            return repeatEveryWeek(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch, weekTerm: 1)
        case .everySecondWeek:
            return repeatEverySecondWeek(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch)
        case .everyMonth:
            return repeatEveryMonth(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch)
        case .everyYear:
            return repeatEveryYear(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch)
        default:
            return [Schedule]()
        }
    }
    
    // 2일 이상치 일정의 반복
    func successionRepeatSchedule(firstDate: Date, curDate: Date, lastDate: Date, oriRepeatSch: Schedule) -> [Schedule] {
        var paramCurDate: Date?
        if firstDate.month != curDate.month || lastDate.month != curDate.month {
            paramCurDate = curDate
        }
        
        switch oriRepeatSch.repeatOption {
        case .everyWeek:
            return sucRepeatEveryWeek(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch, weekTerm: 1)
        case .everySecondWeek:
            return sucRepeatEveryWeek(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch, weekTerm: 2)
        case .everyMonth:
            return sucRepeatEveryMonth(firstDate: firstDate, curDate: paramCurDate, lastDate: lastDate, schedule: oriRepeatSch)
        case .everyYear:
            return sucRepeatEveryYear(firstDate: firstDate, curDate: paramCurDate, lastDate: lastDate, schedule: oriRepeatSch)
        default:
            return [Schedule]()
        }
    }

    // repeatXXX 함수의 firstDate = 달력에 표시될 날짜의 첫 시작 date, lastDate = 달력에 표시될 날짜의 마지막 date
    func repeatEveryDay(firstDate: Date, lastDate: Date, schedule: Schedule) -> [Schedule] {
        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        var result = [Schedule]()
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        var prevRepeatEnd: Date? = startDate
        var nextRepeatStart: Date? = startDate
        for date in stride(from: startDate, through: endDate, by: dayDurationInSeconds) {
            // dateComponents에는 달력에 보여질 일정 끝나는 일과 시간
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            var prevDateComp = dateComponents
            prevDateComp.day! -= 1
            if let prevRepEnd = calendar.date(from: prevDateComp) {
                prevRepeatEnd = prevRepEnd
            } else {
                print("[Debug] 날짜 계산에 이상이 있습니다. \(#function) \(#file)")
            }
            
            var nextDateComp = dateComponents
            nextDateComp.day! += 1
            nextDateComp.hour = schedule.repeatStart.hour
            nextDateComp.minute = schedule.repeatStart.minute
            nextDateComp.second = schedule.repeatStart.second
            if let nextRepStart = calendar.date(from: nextDateComp) {
                nextRepeatStart = nextRepStart
            } else {
                print("[Debug] 날짜 계산에 이상이 있습니다. \(#function) \(#file)")
            }
            
            result.append(
                Schedule.createRepeatSchedule(
                    schedule: schedule,
                    repeatStart: date,
                    repeatEnd: calendar.date(from: dateComponents) ?? date,
                    prevRepeatEnd: prevRepeatEnd,
                    nextRepeatStart: nextRepeatStart
                )
            )
        }
        return result
    }
    
    func repeatEveryWeek(firstDate: Date, lastDate: Date, schedule: Schedule, weekTerm: Int) -> [Schedule] {
        var result = [Schedule]()

        var (startDate, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        let day = 60 * 60 * 24
        
        let offset = calendar.component(.weekday, from: startDate) - 1
        
        var repeatValue = [Int]()
        for i in schedule.repeatValue! {
            if i.isNumber {
                repeatValue.append(Int(String(i))!)
            }
        }
        
//        if weekTerm == 2, startDate.month != schedule.repeatStart.month || startDate.day != schedule.repeatStart.day {
//            let diff = CalendarHelper.getDiffWeeks(date1: schedule.repeatStart, date2: startDate)
//            if diff % 2 == 0 {
//                startDate = startDate.addingTimeInterval(TimeInterval(day * 7))
//            }
//        }
        
        // 최대 6개의 주가 있을 수 있으니 6번 반복 (추후에 더 좋게 구현 할 것)
        for _ in 0 ... 5 {
            for idx in repeatValue.indices {
                if repeatValue[(idx + offset) % 7] == 1 {
                    guard let repeatStart = CalendarHelper.getClosestIdxDate(idx: (idx + offset) % 7 + 1, curDate: calendar.startOfDay(for: startDate)) else {
                        print("[Error] getClosestIdxDate 함수 에러 \(#fileID) \(#function)")
                        continue
                    }
                    
                    if repeatStart > endDate {
                        break
                    }
                    
                    dateComponents = calendar.dateComponents([.year, .month, .day], from: repeatStart)
                    dateComponents.hour = startDate.hour
                    dateComponents.minute = startDate.minute
                    dateComponents.second = startDate.second
                    
                    guard let repeatStart = calendar.date(from: dateComponents) else {
                        print("[Error] startDate의 hour: \(startDate.hour) \(startDate.minute) \(#fileID) \(#function)")
                        continue
                    }
                    
                    dateComponents.hour = endDate.hour
                    dateComponents.minute = endDate.minute
                    dateComponents.second = endDate.second
                    
                    guard let repeatEnd = calendar.date(from: dateComponents) else {
                        print("[Error] endDate의 hour: \(endDate.hour) \(endDate.minute) \(#fileID) \(#function)")
                        continue
                    }
                    
                    // nextRepeatStart와 prevRepeatEnd 찾기
                    
                    var nextRepeatStart: Date = repeatStart.addingTimeInterval(TimeInterval(day))
                    var prevRepeatEnd: Date = repeatEnd.addingTimeInterval(TimeInterval(-day))
                    var index = (calendar.component(.weekday, from: repeatStart)) % 7
                    var revIndex = (calendar.component(.weekday, from: repeatEnd) - 2)
                    revIndex = revIndex < 0 ? 6 : revIndex
                    if weekTerm == 1 {
                        while repeatValue[index] == 0 {
                            nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                            index = (index + 1) % 7
                        }
                        
                        while repeatValue[revIndex] == 0 {
                            prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-day))
                            if revIndex - 1 < 0 {
                                revIndex = 6
                            } else {
                                revIndex = revIndex - 1
                            }
                        }
                    } else if weekTerm == 2 {
                        if index == 0 {
                            nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day * 7))
                        }
                        if revIndex == 0 {
                            prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-(day * 7)))
                        }

                        while repeatValue[index] == 0 {
                            nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day))
                            index = (index + 1) % 7

                            if index == 0 {
                                nextRepeatStart = nextRepeatStart.addingTimeInterval(TimeInterval(day * 7))
                            }
                        }
                        
                        while repeatValue[revIndex] == 0 {
                            prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-day))
                            if revIndex - 1 < 0 {
                                revIndex = 6
                            } else {
                                revIndex = revIndex - 1
                            }
                            
                            if revIndex == 0 {
                                prevRepeatEnd = prevRepeatEnd.addingTimeInterval(TimeInterval(-(day * 7)))
                            }
                        }
                    }
                    
                    result.append(
                        Schedule.createRepeatSchedule(
                            schedule: schedule,
                            repeatStart: repeatStart,
                            repeatEnd: repeatEnd,
                            prevRepeatEnd: prevRepeatEnd,
                            nextRepeatStart: nextRepeatStart
                        )
                    )
                }
            }
            if let nextStartDate = calendar.date(byAdding: .weekOfYear, value: weekTerm, to: startDate) {
                startDate = nextStartDate
            }
        }
        
        return result
    }
    
    func repeatEverySecondWeek(firstDate: Date, lastDate: Date, schedule: Schedule) -> [Schedule] {
        var result = [Schedule]()
        
        if schedule.repeatValue == nil {
            print("[Error] scheduleId: \(schedule.id)에 repeatValue에 이상이 있습니다. \(#fileID) \(#function)")
            return result
        }
        
        let (_, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        dateComponents = calendar.dateComponents([.year, .month, .day], from: schedule.repeatStart)
        dateComponents.hour = schedule.repeatEnd.hour
        dateComponents.minute = schedule.repeatEnd.minute
        dateComponents.second = schedule.repeatEnd.second
        
        var curRepStartDate: Date = schedule.repeatStart
        guard var curRepEndDate = calendar.date(from: dateComponents) else {
            return result
        }
        
        var prevRepeatEnd = Date()
        var nextRepeatStart = Date()
        
        let resultSchedule = schedule
        
        while curRepStartDate <= endDate {
            do {
                prevRepeatEnd = try resultSchedule.prevRepeatEndDate(curRepeatEnd: curRepEndDate)
            } catch {
                print("[Debug] prevRepeatEndDate에 이상이 있습니다. \(#function) \(#file)")
            }
            
            do {
                nextRepeatStart = try resultSchedule.nextRepeatStartDate(curRepeatStart: curRepStartDate)
            } catch {
                print("[Debug] nextRepeatStartDate에 이상이 있습니다. \(#function) \(#file)")
            }
            
            result.append(
                Schedule.createRepeatSchedule(
                    schedule: resultSchedule,
                    repeatStart: curRepStartDate,
                    repeatEnd: curRepEndDate,
                    prevRepeatEnd: prevRepeatEnd,
                    nextRepeatStart: nextRepeatStart
                )
            )
            
            curRepStartDate = nextRepeatStart
            
            do {
                curRepEndDate = try resultSchedule.nextRepeatStartDate(curRepeatStart: curRepEndDate)
            } catch {
                print("[Debug] nextRepeatStartDate에 이상이 있습니다. \(#function) \(#file)")
            }
        }
        
        return result
    }
    
    func repeatEveryMonth(firstDate: Date, lastDate: Date, schedule: Schedule) -> [Schedule] {
        var result = [Schedule]()
        
        guard let repeatValue = schedule.repeatValue else {
            print("[Error] scheduleId: \(schedule.id)에 repeatValue에 이상이 있습니다. \(#fileID) \(#function)")
            return result
        }
        
        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for date in stride(from: startDate, through: endDate, by: dayDurationInSeconds) {
            if repeatValue[repeatValue.index(repeatValue.startIndex, offsetBy: date.day - 1)] == "1" {
                dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                dateComponents.hour = schedule.repeatStart.hour
                dateComponents.minute = schedule.repeatStart.minute
                dateComponents.second = schedule.repeatStart.second
                
                guard let curRepeatStart = calendar.date(from: dateComponents) else {
                    print("[Error] schedule.repeatStart가 Date 타입이 아닙니다. \(#fileID) \(#function)")
                    continue
                }
                
                dateComponents.hour = schedule.repeatEnd.hour
                dateComponents.minute = schedule.repeatEnd.minute
                dateComponents.second = schedule.repeatEnd.second
                
                guard let curRepeatEnd = calendar.date(from: dateComponents) else {
                    print("[Error] schedule.repeatEnd가 Date 타입이 아닙니다. \(#fileID) \(#function)")
                    continue
                }
                
                var nextRepeatStart: Date?
                do {
                    nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: curRepeatStart)
                } catch (let error) {
                    print("[Error] \(error) \(#fileID) \(#function)")
                    continue
                }
                
                var prevRepeatEnd: Date?
                do {
                    prevRepeatEnd = try schedule.prevRepeatEndDate(curRepeatEnd: curRepeatEnd)
                } catch (let error) {
                    print("[Error] \(error) \(#fileID) \(#function)")
                }
                
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: curRepeatStart,
                        repeatEnd: curRepeatEnd,
                        prevRepeatEnd: prevRepeatEnd,
                        nextRepeatStart: nextRepeatStart
                    )
                )
            }
        }
        
        return result
    }
    
    func repeatEveryYear(firstDate: Date, lastDate: Date, schedule: Schedule) -> [Schedule] {
        var result = [Schedule]()
        
        guard schedule.repeatValue != nil else {
            print("[Error] scheduleId: \(schedule.id)에 repeatValue에 이상이 있습니다. \(#fileID) \(#function)")
            return result
        }
        
        let (_, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        var prevRepeatEnd = schedule.repeatStart
        var checkDate = schedule.repeatStart
        
        while checkDate < firstDate, checkDate < endDate {
            prevRepeatEnd = checkDate
            do {
                checkDate = try schedule.nextRepeatStartDate(curRepeatStart: checkDate)
            } catch {
                print("[Error] schedule nextRepeatStartDate 함수의 매년 로직 다시 구현")
                print("\(#fileID) \(#function)")
            }
        }
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        while firstDate <= checkDate, checkDate < endDate {
            var nextRepeatStart = checkDate
            do {
                nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: checkDate)
            } catch {
                print("[Error] schedule nextRepeatStartDate 함수의 매년 로직 다시 구현")
                print("\(#fileID) \(#function)")
            }
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: checkDate)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            guard let repeatEnd = calendar.date(from: dateComponents) else {
                print("[Error] endDate의 hour: \(endDate.hour) \(endDate.minute) \(#fileID) \(#function)")
                continue
            }
            
            result.append(
                Schedule.createRepeatSchedule(
                    schedule: schedule,
                    repeatStart: checkDate,
                    repeatEnd: repeatEnd,
                    prevRepeatEnd: prevRepeatEnd,
                    nextRepeatStart: nextRepeatStart
                )
            )
            checkDate = nextRepeatStart
        }
        
        return result
    }
    
    // MARK: TODO: 긴 반복 일정 로직 구현

    func sucRepeatEveryWeek(firstDate: Date, lastDate: Date, schedule: Schedule, weekTerm: Int) -> [Schedule] {
        var result = [Schedule]()
        
        guard let repeatValue = schedule.repeatValue else {
            print("[Error] scheduleId: \(schedule.id)에 repeatValue에 이상이 있습니다. \(#fileID) \(#function)")
            return result
        }
        
        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        let day = 60 * 60 * 24
        
        let idx = CalendarHelper.getDayofWeek(date: schedule.repeatStart)
        var pivotRepStart = CalendarHelper.getClosestDayOfWeekDate(idx: idx, baseDate: startDate)
        
        // FIXME: 뭔가 이상함
        if weekTerm == 2, startDate.month != schedule.repeatStart.month || startDate.day != schedule.repeatStart.day {
            let diff = CalendarHelper.getDiffWeeks(date1: schedule.repeatStart, date2: startDate)
            if diff % 2 == 0 {
                pivotRepStart = pivotRepStart.addingTimeInterval(TimeInterval(day * 7))
            }
        }
        
        var nextRepeatStart: Date = pivotRepStart.addingTimeInterval(TimeInterval(day * 7 * weekTerm))
        var prevRepeatEnd: Date = pivotRepStart.addingTimeInterval(TimeInterval(-(day * 7 * weekTerm)))
        while pivotRepStart < endDate {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: pivotRepStart)
            dateComponents.hour = schedule.repeatStart.hour
            dateComponents.minute = schedule.repeatStart.minute
            dateComponents.second = schedule.repeatStart.second
            
            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                continue
            }
            
            let repeatEnd_ = repeatStart.addingTimeInterval(
                TimeInterval(
                    Double(
                        repeatValue.split(separator: "T")[0]
                    ) ?? 0
                )
            )
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: repeatEnd_)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            guard let repeatEnd = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                continue
            }
            
            result.append(
                Schedule.createRepeatSchedule(
                    schedule: schedule,
                    repeatStart: repeatStart,
                    repeatEnd: repeatEnd,
                    prevRepeatEnd: prevRepeatEnd,
                    nextRepeatStart: nextRepeatStart
                )
            )
            
            prevRepeatEnd = pivotRepStart
            pivotRepStart = pivotRepStart.addingTimeInterval(TimeInterval(day * 7 * weekTerm))
            nextRepeatStart = pivotRepStart.addingTimeInterval(TimeInterval(day * 7 * weekTerm))
        }
        
        return result
    }
    
    func sucRepeatEveryMonth(firstDate: Date, curDate: Date?, lastDate: Date, schedule: Schedule) -> [Schedule] {
        var result = [Schedule]()
        guard let repeatValue = schedule.repeatValue else {
            print("[Error] scheduleId: \(schedule.id)에 repeatValue에 이상이 있습니다. \(#fileID) \(#function)")
            return result
        }

        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateStringPrev = "\(firstDate.year)-\(firstDate.month)-\(schedule.repeatStart.day)"
        var dateStringCur: String?
        if let curDate {
            dateStringCur = "\(curDate.year)-\(curDate.month)-\(schedule.repeatStart.day)"
        }
        let dateStringNext = "\(lastDate.year)-\(lastDate.month)-\(schedule.repeatStart.day)"
        
        if let date1 = dateFormatter.date(from: dateStringPrev),
           firstDate <= date1, date1 < lastDate.addDay()
        {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date1)
            dateComponents.hour = schedule.repeatStart.hour
            dateComponents.minute = schedule.repeatStart.minute
            dateComponents.second = schedule.repeatStart.second
            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return result
            }
            
            let repeatEnd_ = repeatStart.addingTimeInterval(
                TimeInterval(
                    Double(
                        repeatValue.split(separator: "T")[0]
                    ) ?? 0
                )
            )
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: repeatEnd_)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            guard let repeatEnd = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return result
            }
            
            // 달이 넘어가는지 분기처리
            if repeatStart.month == repeatEnd.month {
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: repeatStart,
                        repeatEnd: repeatEnd,
                        prevRepeatEnd: CalendarHelper.prevMonthDate(curDate: repeatStart),
                        nextRepeatStart: CalendarHelper.nextMonthDate(curDate: repeatStart)
                    )
                )
            } else {
                dateComponents = calendar.dateComponents([.year, .month], from: repeatStart)
                dateComponents.day = CalendarHelper.numberOfDaysInMonth(date: repeatStart)
                dateComponents.hour = 23
                dateComponents.minute = 55
                
                guard let repeatEnd = calendar.date(from: dateComponents) else {
                    print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                    return result
                }
                
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: repeatStart,
                        repeatEnd: repeatEnd,
                        prevRepeatEnd: CalendarHelper.prevMonthDate(curDate: repeatStart),
                        nextRepeatStart: CalendarHelper.nextMonthDate(curDate: repeatStart)
                    )
                )
            }
        }
        
        if let dateStringCur,
           let date2 = dateFormatter.date(from: dateStringCur),
           date2.month != firstDate.month || date2.month != lastDate.month,
           firstDate <= date2, date2 < lastDate.addDay()
        {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date2)
            dateComponents.hour = schedule.repeatStart.hour
            dateComponents.minute = schedule.repeatStart.minute
            dateComponents.second = schedule.repeatStart.second
            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return []
            }
            
            let repeatEnd_ = repeatStart.addingTimeInterval(
                TimeInterval(
                    Double(
                        repeatValue.split(separator: "T")[0]
                    ) ?? 0
                )
            )
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: repeatEnd_)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            guard let repeatEnd = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return result
            }
            
            // 달이 넘어가는지 분기처리
            if repeatStart.month == repeatEnd.month {
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: repeatStart,
                        repeatEnd: repeatEnd,
                        prevRepeatEnd: CalendarHelper.prevMonthDate(curDate: repeatStart),
                        nextRepeatStart: CalendarHelper.nextMonthDate(curDate: repeatStart)
                    )
                )
            } else {
                dateComponents = calendar.dateComponents([.year, .month], from: repeatStart)
                dateComponents.day = CalendarHelper.numberOfDaysInMonth(date: repeatStart)
                dateComponents.hour = 23
                dateComponents.minute = 55
                
                guard let repeatEnd = calendar.date(from: dateComponents) else {
                    print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                    return result
                }
                
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: repeatStart,
                        repeatEnd: repeatEnd,
                        prevRepeatEnd: CalendarHelper.prevMonthDate(curDate: repeatStart),
                        nextRepeatStart: CalendarHelper.nextMonthDate(curDate: repeatStart)
                    )
                )
            }
        }
        
        if let date3 = dateFormatter.date(from: dateStringNext),
           firstDate <= date3, date3 < lastDate.addDay()
        {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date3)
            dateComponents.hour = schedule.repeatStart.hour
            dateComponents.minute = schedule.repeatStart.minute
            dateComponents.second = schedule.repeatStart.second
            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return []
            }
            
            let repeatEnd_ = repeatStart.addingTimeInterval(
                TimeInterval(
                    Double(
                        repeatValue.split(separator: "T")[0]
                    ) ?? 0
                )
            )
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: repeatEnd_)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            guard let repeatEnd = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return result
            }
            
            // 달이 넘어가는지 분기처리
            if repeatStart.month == repeatEnd.month {
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: repeatStart,
                        repeatEnd: repeatEnd,
                        prevRepeatEnd: CalendarHelper.prevMonthDate(curDate: repeatStart),
                        nextRepeatStart: CalendarHelper.nextMonthDate(curDate: repeatStart)
                    )
                )
            } else {
                dateComponents = calendar.dateComponents([.year, .month], from: repeatStart)
                dateComponents.day = CalendarHelper.numberOfDaysInMonth(date: repeatStart)
                dateComponents.hour = 23
                dateComponents.minute = 55
                
                guard let repeatEnd = calendar.date(from: dateComponents) else {
                    print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                    return result
                }
                
                result.append(
                    Schedule.createRepeatSchedule(
                        schedule: schedule,
                        repeatStart: repeatStart,
                        repeatEnd: repeatEnd,
                        prevRepeatEnd: CalendarHelper.prevMonthDate(curDate: repeatStart),
                        nextRepeatStart: CalendarHelper.nextMonthDate(curDate: repeatStart)
                    )
                )
            }
        }
        
        return result
    }
    
    func sucRepeatEveryYear(firstDate: Date, curDate: Date?, lastDate: Date, schedule: Schedule) -> [Schedule] {
        var result = [Schedule]()
        guard let repeatValue = schedule.repeatValue else {
            print("[Error] scheduleId: \(schedule.id)에 repeatValue에 이상이 있습니다. \(#fileID) \(#function)")
            return result
        }
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var dateString = ""
        
        if schedule.repeatStart.month == firstDate.month {
            dateString = "\(firstDate.year)-\(firstDate.month)-\(schedule.repeatStart.day)"
        } else if let curDate, schedule.repeatStart.month == curDate.month {
            dateString = "\(curDate.year)-\(curDate.month)-\(schedule.repeatStart.day)"
        } else if schedule.repeatStart.month == lastDate.month {
            dateString = "\(lastDate.year)-\(lastDate.month)-\(schedule.repeatStart.day)"
        } else if (schedule.repeatStart.month + 1) % 12 == firstDate.month,
                  firstDate.month == curDate?.month
        {
            let pivotDate = firstDate.addingTimeInterval(TimeInterval(-(60 * 60 * 24)))
            dateString = "\(pivotDate.year)-\(pivotDate.month)-\(schedule.repeatStart.day)"
        }
        
        if let date = dateFormatter.date(from: dateString) {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = schedule.repeatStart.hour
            dateComponents.minute = schedule.repeatStart.minute
            dateComponents.second = schedule.repeatStart.second
            
            guard let repeatStart = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return result
            }
            
            let repeatEnd_ = repeatStart.addingTimeInterval(
                TimeInterval(
                    Double(
                        repeatValue.split(separator: "T")[0]
                    ) ?? 0
                )
            )
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: repeatEnd_)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute
            dateComponents.second = schedule.repeatEnd.second
            
            guard let repeatEnd = calendar.date(from: dateComponents) else {
                print("[Error] scheduleId: \(schedule.id)에 문제가 있습니다. \(#fileID) \(#function)")
                return result
            }
            
            result.append(
                Schedule.createRepeatSchedule(
                    schedule: schedule,
                    repeatStart: repeatStart,
                    repeatEnd: repeatEnd,
                    prevRepeatEnd: CalendarHelper.prevYearDate(curDate: repeatStart),
                    nextRepeatStart: CalendarHelper.nextYearDate(curDate: repeatStart)
                )
            )
        }
        
        return result
    }
    
    // MARK: - 반복 TODO 만들어주기

    func makeRepeatTodo(
        firstDate: Date,
        lastDate: Date,
        repeatTodoList: [Todo]
    ) -> [Todo] {
        var result = [Todo]()
        for todo in repeatTodoList {
            result.append(contentsOf: singleRepeatTodo(firstDate: firstDate, lastDate: lastDate, oriRepeatTodo: todo))
        }
        return result
    }
    
    func singleRepeatTodo(firstDate: Date, lastDate: Date, oriRepeatTodo: Todo) -> [Todo] {
        switch oriRepeatTodo.repeatOption {
        case .everyDay:
            return repeatEveryDay(firstDate: firstDate, lastDate: lastDate, todo: oriRepeatTodo)
        case .everyWeek:
            return repeatEveryWeek(firstDate: firstDate, lastDate: lastDate, todo: oriRepeatTodo, weekTerm: 1)
        case .everySecondWeek:
            return repeatEveryWeek(firstDate: firstDate, lastDate: lastDate, todo: oriRepeatTodo, weekTerm: 2)
        case .everyMonth:
            return repeatEveryMonth(firstDate: firstDate, lastDate: lastDate, todo: oriRepeatTodo)
        case .everyYear:
            return repeatEveryYear(firstDate: firstDate, lastDate: lastDate, todo: oriRepeatTodo)
        default:
            return [Todo]()
        }
    }
    
    func repeatEveryDay(firstDate: Date, lastDate: Date, todo: Todo) -> [Todo] {
        var result = [Todo]()
        
        guard let todoEndDate = todo.endDate else {
            print("[Error] 반복 Todo는 endDate가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: 2200, month: 1, day: 1)
        let maxRepeatEndDate = calendar.date(from: dateComponents)!

        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(
            firstDate: firstDate,
            repeatStart: todoEndDate,
            lastDate: lastDate,
            repeatEnd: todo.repeatEnd ?? maxRepeatEndDate,
            isTodo: true
        )
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for date in stride(from: startDate, through: endDate, by: dayDurationInSeconds) {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = todoEndDate.hour
            dateComponents.minute = todoEndDate.minute
            dateComponents.second = todoEndDate.second
            
            guard let curEndDate = calendar.date(from: dateComponents) else {
                print("[Error] endDate에 문제가 있습니다. \(#fileID) \(#function)")
                continue
            }
            
            result.append(Todo.createRepeatTodo(todo: todo, endDate: curEndDate))
        }
        
        return result
    }
    
    func repeatEveryWeek(firstDate: Date, lastDate: Date, todo: Todo, weekTerm: Int) -> [Todo] {
        var result = [Todo]()
        
        guard var todoEndDate = todo.endDate else {
            print("[Error] 반복 Todo는 endDate가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        let realRepeatStart = todoEndDate
        
        guard let todoRepeatValue = todo.repeatValue else {
            print("[Error] 반복 Todo는 repeatValue가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: 2200, month: 1, day: 1)
        let maxRepeatEndDate = calendar.date(from: dateComponents)!

        var (startDate, endDate) = CalendarHelper.fittingStartEndDate(
            firstDate: firstDate,
            repeatStart: todoEndDate,
            lastDate: lastDate,
            repeatEnd: todo.repeatEnd ?? maxRepeatEndDate,
            isTodo: true
        )
        
        let offset = calendar.component(.weekday, from: startDate) - 1
        
        let repeatValue = todoRepeatValue.map { $0 == "1" ? 1 : 0 }
        
        if weekTerm == 1 {
            // 최대 6개의 주가 있을 수 있으니 6번 반복 (추후에 더 좋게 구현 할 것)
            for _ in 0 ... 5 {
                for idx in repeatValue.indices {
                    if repeatValue[(idx + offset) % 7] == 1 {
                        guard let curEndDate = CalendarHelper.getClosestIdxDate(idx: (idx + offset) % 7 + 1, curDate: calendar.startOfDay(for: startDate)) else {
                            print("[Error] getClosestIdxDate 함수 에러 \(#fileID) \(#function)")
                            continue
                        }
                        
                        if curEndDate > endDate {
                            break
                        }
                        
                        dateComponents = calendar.dateComponents([.year, .month, .day], from: curEndDate)
                        dateComponents.hour = todoEndDate.hour
                        dateComponents.minute = todoEndDate.minute
                        dateComponents.second = todoEndDate.second
                        guard let curEndDate = calendar.date(from: dateComponents) else {
                            print("[Error] todoEndDate의 hour: \(todoEndDate.hour) \(todoEndDate.minute) \(#fileID) \(#function)")
                            continue
                        }
                        
                        result.append(Todo.createRepeatTodo(todo: todo, endDate: curEndDate))
                    }
                }
                if let nextStartDate = calendar.date(byAdding: .weekOfYear, value: weekTerm, to: startDate) {
                    startDate = nextStartDate
                }
            }
        } else {
            var todo = todo
            result.append(Todo.createRepeatTodo(todo: todo, endDate: todoEndDate, realRepeatStart: realRepeatStart))
            while todoEndDate <= endDate {
                do {
                    guard let nextEndDate = try todo.nextEndDate() else {
                        return result
                    }
                    
                    todo.endDate = nextEndDate
                    todoEndDate = nextEndDate
                    
                } catch {
                    print("[Debug] nextEndDate 함수가 잘 못되었습니다. \(#function) \(#file)")
                }
                
                result.append(Todo.createRepeatTodo(todo: todo, endDate: todoEndDate, realRepeatStart: realRepeatStart))
            }
        }
        
        return result
    }
    
    func repeatEveryMonth(firstDate: Date, lastDate: Date, todo: Todo) -> [Todo] {
        var result = [Todo]()
        
        guard let todoEndDate = todo.endDate else {
            print("[Error] 반복 Todo는 endDate가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        guard let todoRepeatValue = todo.repeatValue else {
            print("[Error] 반복 Todo는 repeatValue가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: 2200, month: 1, day: 1)
        let maxRepeatEndDate = calendar.date(from: dateComponents)!

        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(
            firstDate: firstDate,
            repeatStart: todoEndDate,
            lastDate: lastDate,
            repeatEnd: todo.repeatEnd ?? maxRepeatEndDate,
            isTodo: true
        )
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        let repeatValue = todoRepeatValue.map { $0 == "1" ? 1 : 0 }
        
        for date in stride(from: startDate, through: endDate, by: dayDurationInSeconds) {
            if repeatValue[date.day - 1] == 1 {
                dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                dateComponents.hour = todoEndDate.hour
                dateComponents.minute = todoEndDate.minute
                dateComponents.second = todoEndDate.second
                guard let curEndDate = calendar.date(from: dateComponents) else {
                    print("[Error] todoEndDate의 hour: \(todoEndDate.hour) \(todoEndDate.minute) \(#fileID) \(#function)")
                    continue
                }
                
                result.append(Todo.createRepeatTodo(todo: todo, endDate: curEndDate))
            }
        }
        
        return result
    }
    
    func repeatEveryYear(firstDate: Date, lastDate: Date, todo: Todo) -> [Todo] {
        var result = [Todo]()
        
        guard let todoEndDate = todo.endDate else {
            print("[Error] 반복 Todo는 endDate가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        guard let todoRepeatValue = todo.repeatValue else {
            print("[Error] 반복 Todo는 repeatValue가 반드시 필요합니다. \(#fileID) \(#function)")
            return result
        }
        
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: 2200, month: 1, day: 1)
        let maxRepeatEndDate = calendar.date(from: dateComponents)!

        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(
            firstDate: firstDate,
            repeatStart: todoEndDate,
            lastDate: lastDate,
            repeatEnd: todo.repeatEnd ?? maxRepeatEndDate,
            isTodo: true
        )
        
        let repeatValue = todoRepeatValue.map { $0 == "1" ? 1 : 0 }
        
        var comp = startDate.month
        for month in startDate.month ... (endDate.month < startDate.month ? 12 + endDate.month : endDate.month) {
            if repeatValue[(month - 1) % 12] == 1 {
                let dateString = "\(comp < month ? startDate.year : endDate.year)-\(month)-\(todoEndDate.day)"
                if let curEndDate = CalendarHelper.stringToDate(dateString: dateString, curDate: todo.endDate) {
                    result.append(Todo.createRepeatTodo(todo: todo, endDate: curEndDate))
                }
            }
            comp = month
        }

        return result
    }
}
