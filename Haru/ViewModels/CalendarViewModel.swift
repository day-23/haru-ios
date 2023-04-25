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
    
    // MARK: - DetailView에 보여질 데이터들

    @Published var scheduleList: [[Schedule]] = []
    @Published var todoList: [[Todo]] = []
    @Published var pivotDateList: [Date] = []
    @Published var pivotDate: Date = .init()
    
    @Published var startOnSunday: Bool = true
    
    @Published var monthOffest: Int = 0 {
        didSet {
            getCurDateList(monthOffest, startOnSunday)
        }
    } // 진짜 월과의 차이
    
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

    // MARK: 달력에 해당하는 월에 맞는 스케줄 + 할일 표시해주기 위한 함수

    func getCurMonthSchList(_ dateList: [DateValue]) {
        productivityList = [[Int: [Productivity]]](repeating: [:], count: dateList.count)
        viewProductivityList = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: maxOrder), count: numberOfWeeks)
        
        guard let firstDate = dateList.first?.date, let startDate = Calendar.current.date(byAdding: .day, value: -1, to: firstDate) else { return }
        guard let lastDate = dateList.last?.date, let endDate = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) else { return }
        
        Task {
            var beforeRepeat = await calendarService.fetchScheduleAndTodo(startDate, endDate)
            
            // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
            var repeatScheduleList = [Schedule]()
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
            
            beforeRepeat.0.append(contentsOf: makeRepeatSchedule(firstDate: firstDate, lastDate: lastDate, repeatScheduleList: repeatScheduleList))
            // beforeRepeat.1.append(...)
            
            let result = (beforeRepeat.0.sorted {
                $0.repeatStart < $1.repeatStart
            }, beforeRepeat.1)
            
            DispatchQueue.main.async {
                (self.productivityList, self.viewProductivityList) = self.fittingCalendar(dateList: dateList, scheduleList: result.0, todoList: result.1)
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
        scheduleList = [[Schedule]](repeating: [], count: 31)
        todoList = [[Todo]](repeating: [], count: 31)
        pivotDateList = [Date](repeating: Date(), count: 31)
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: -15, to: pivotDate) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: 15, to: pivotDate) else { return }
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for (index, date) in stride(from: startDate, through: endDate, by: dayDurationInSeconds).enumerated() {
            pivotDateList[index] = date
        }
        
        Task {
            var beforeRepeat = await calendarService.fetchScheduleAndTodo(startDate, endDate)
            
            // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
            var repeatScheduleList = [Schedule]()
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
            
            beforeRepeat.0.append(contentsOf: makeRepeatSchedule(firstDate: startDate, lastDate: endDate, repeatScheduleList: repeatScheduleList))
            let result = (beforeRepeat.0.sorted {
                $0.repeatStart < $1.repeatStart
            }, beforeRepeat.1)
            
            DispatchQueue.main.async {
                (self.scheduleList, self.todoList) = self.fittingDay(startDate, endDate, scheduleList: result.0, todoList: result.1)
            }
        }
    }
    
    // 수정 및 저장과 같은 이벤트가 있을 때 새로고침을 위한 함수
    func getRefreshProductivityList() {
        guard let startDate = pivotDateList.first else { return }
        guard let endDate = pivotDateList.last else { return }
        
        scheduleList = [[Schedule]](repeating: [], count: 31)
        todoList = [[Todo]](repeating: [], count: 31)
        pivotDateList = [Date](repeating: Date(), count: 31)
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for (index, date) in stride(from: startDate, through: endDate, by: dayDurationInSeconds).enumerated() {
            pivotDateList[index] = date
        }
        
        Task {
            var beforeRepeat = await calendarService.fetchScheduleAndTodo(startDate, endDate)
            
            // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
            var repeatScheduleList = [Schedule]()
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
            
            beforeRepeat.0.append(contentsOf: makeRepeatSchedule(firstDate: startDate, lastDate: endDate, repeatScheduleList: repeatScheduleList))
            let result = (beforeRepeat.0.sorted {
                $0.repeatStart < $1.repeatStart
            }, beforeRepeat.1)
            
            DispatchQueue.main.async {
                (self.scheduleList, self.todoList) = self.fittingDay(startDate, endDate, scheduleList: result.0, todoList: result.1)
            }
        }
    }
    
    // offSet만큼 더해주고 빼주깈
    func getMoreProductivityList(isRight: Bool, offSet: Int, completion: @escaping () -> Void) {
        guard let toDate = isRight ? pivotDateList.last : pivotDateList.first else { return }
        let startValue = isRight ? 1 : -offSet
        let endValue = isRight ? offSet : -1
        
        guard let startDate = Calendar.current.date(byAdding: .day, value: startValue, to: toDate) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: endValue, to: toDate) else { return }
        
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24

        Task {
            var beforeRepeat = await calendarService.fetchScheduleAndTodo(startDate, endDate)
            
            // FIXME: 반복해야할 스케줄 (나중에는 할일도 넣어줄 수 있게 로직 변경 필요)
            var repeatScheduleList = [Schedule]()
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
            
            beforeRepeat.0.append(contentsOf: makeRepeatSchedule(firstDate: startDate, lastDate: endDate, repeatScheduleList: repeatScheduleList))
            let result = (beforeRepeat.0.sorted {
                $0.repeatStart < $1.repeatStart
            }, beforeRepeat.1)
            
            DispatchQueue.main.async {
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
    func addCategory(_ content: String, _ color: String?, completion: @escaping () -> Void) {
        let category = Request.Category(content: content, color: color != nil ? "#" + color! : nil)
        
        categoryList.append(Category(id: UUID().uuidString, content: content, color: color, isSelected: true))
        let index = categoryList.endIndex - 1
        
        categoryService.addCategory(category) { result in
            switch result {
            case .success(let success):
                self.categoryList[index] = success
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
    ) -> ([[Int: [Productivity]]], [[[(Int, Productivity?)]]]) {
        // 주차 개수
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 최대 보여줄 수 있는 일정, 할일 개수
        let prodCnt = maxOrder

        // 최종 결과
        var result = [[Int: [Productivity]]](repeating: [:], count: dateList.count) // 날짜별

        var result_ = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: prodCnt), count: numberOfWeeks) // 달력에 보여질 결과물

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
        result: inout [[Int: [Productivity]]],
        result_: inout [[[(Int, Productivity?)]]]
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
        result: inout [[Int: [Productivity]]]
    ) {
        let todoList = todoList.filter { $0.endDate != nil }
        var todoIdx = 0, dateIdx = 0

        var maxKey = result[dateIdx].max { $0.key < $1.key }?.key ?? -1
        maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
        while todoIdx < todoList.count, dateIdx < dateList.count {
            if dateList[dateIdx].date.isEqual(other: todoList[todoIdx].endDate!) {
                result[dateIdx][maxKey] = (result[dateIdx][maxKey] ?? []) + [todoList[todoIdx]]
                maxKey = maxKey >= prodCnt ? maxKey : maxKey + 1
                todoIdx += 1
            } else if dateList[dateIdx].date > todoList[todoIdx].endDate! {
                todoIdx += 1
            } else {
                dateIdx += 1
                if dateIdx < dateList.count {
                    maxKey = result[dateIdx].max { $0.key < $1.key }?.key ?? -1
                    maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
                }
            }
        }
    }
    
    // MARK: - 반복 일정 만들어주기

    /**
     * 반복인 일정들만 repeatSchList에 받아와서 반복 (일정)데이터 만들어서 리턴
     */
    func makeRepeatSchedule(
        firstDate: Date,
        lastDate: Date,
        repeatScheduleList: [Schedule]
    ) -> [Schedule] {
        var result = [Schedule]()
        for sch in repeatScheduleList {
            // make schedule
            if sch.repeatValue?.first == "T" {
                // TODO: 연속된 일정 반복 처리
            } else {
                result.append(contentsOf: singleRepeatSchedule(firstDate: firstDate, lastDate: lastDate, oriRepeatSch: sch))
            }
        }
        return result
    }

    // 하루치 일정의 반복 (repeatValue: 0,1)
    func singleRepeatSchedule(firstDate: Date, lastDate: Date, oriRepeatSch: Schedule) -> [Schedule] {
        switch oriRepeatSch.repeatOption {
        case "매일":
            return repeatEveryDay(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch)
        case "매주":
            return repeatEveryWeek(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch, weekTerm: 1)
        case "2주마다":
            return repeatEveryWeek(firstDate: firstDate, lastDate: lastDate, schedule: oriRepeatSch, weekTerm: 2)
        case "매달":
            return [Schedule]()
        case "매년":
            return [Schedule]()
        default:
            return [Schedule]()
        }
    }

    func repeatEveryDay(firstDate: Date, lastDate: Date, schedule: Schedule) -> [Schedule] {
        let (startDate, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        var result = [Schedule]()
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        
        for date in stride(from: startDate, through: endDate, by: dayDurationInSeconds) {
            dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = schedule.repeatEnd.hour
            dateComponents.minute = schedule.repeatEnd.minute

            result.append(Schedule.createRepeatSchedule(schedule: schedule, repeatStart: date, repeatEnd: calendar.date(from: dateComponents) ?? date))
        }
        return result
    }
    
    func repeatEveryWeek(firstDate: Date, lastDate: Date, schedule: Schedule, weekTerm: Int) -> [Schedule] {
        
        var result = [Schedule]()

        var (startDate, endDate) = CalendarHelper.fittingStartEndDate(firstDate: firstDate, repeatStart: schedule.repeatStart, lastDate: lastDate, repeatEnd: schedule.repeatEnd)
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        let offset = calendar.component(.weekday, from: startDate) - 1
        
        var repeatValue = [Int]()
        for i in schedule.repeatValue! {
            if i.isNumber {
                repeatValue.append(Int(String(i))!)
            }
        }
        
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
                    guard let repeatStart = calendar.date(from: dateComponents) else {
                        print("[Error] startDate의 hour: \(startDate.hour) \(startDate.minute) \(#fileID) \(#function)")
                        continue
                    }
                    
                    dateComponents.hour = endDate.hour
                    dateComponents.minute = endDate.minute
                    guard let repeatEnd = calendar.date(from: dateComponents) else {
                        print("[Error] endDate의 hour: \(endDate.hour) \(endDate.minute) \(#fileID) \(#function)")
                        continue
                    }
                    result.append(Schedule.createRepeatSchedule(schedule: schedule, repeatStart: repeatStart, repeatEnd: repeatEnd))
                }
            }
            if let nextStartDate = calendar.date(byAdding: .weekOfYear, value: weekTerm, to: startDate) {
                startDate = nextStartDate
            }
        }
        
        return result
    }
}
