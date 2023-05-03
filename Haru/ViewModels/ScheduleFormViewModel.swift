//
//  ScheduleFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import Foundation
import SwiftUI

final class ScheduleFormViewModel: ObservableObject {
    // TODO: 반복 설정, 하루종일 설정
    
    // 추가 or 수정
    var scheduleId: String?
    var mode: ScheduleFormMode
    
    // 초기 값
    var tmpRepeatStart: Date
    var tmpRepeatEnd: Date
    var tmpRepeatOption: String?
    var tmpRepeatValue: String?
    var tmpIsSelectedRepeatEnd: Bool
    var tmpRealRepeatEnd: Date
    
    // 수정 시 필요한 추가 정보
    var realRepeatStart: Date?
    var prevRepeatEnd: Date?
    var nextRepeatStart: Date?
    
    @Published var repeatStart: Date
    @Published var repeatEnd: Date
    @Published var realRepeatEnd: Date
    
    // 시작과 끝이 7일 이상인가
    var overWeek: Bool {
        let startDate = CalendarHelper.removeTimeData(date: repeatStart)
        let endDate = CalendarHelper.removeTimeData(date: repeatEnd)
        
        return startDate.distance(to: endDate) >= 86400.0 * 7
    }
    
    // 시작과 끝이 1일 이상인가
    var overDay: Bool {
        let startDate = CalendarHelper.removeTimeData(date: repeatStart)
        let endDate = CalendarHelper.removeTimeData(date: repeatEnd)
    
        return startDate.distance(to: endDate) >= 86400.0
    }
    
    @Published var content: String = ""
    @Published var memo: String = ""
    
    @Published var isAllDay: Bool = false
    @Published var isSelectedAlarm: Bool = false
    @Published var selectIdxList = [Bool](repeating: false, count: 4) // 선택된 알람
    
    @Published var isSelectedRepeat: Bool = false
    @Published var repeatOption: RepeatOption = .everyDay
    
    @Published var repeatDay: String = "1"

    @Published var repeatWeek: [Day] = [Day(content: "일"), Day(content: "월"), Day(content: "화"),
                                        Day(content: "수"), Day(content: "목"), Day(content: "금"), Day(content: "토")]
    {
        didSet {
            if mode == .edit {
                return
            }

            var nextStartDate = repeatStart
            var nextEndDate = repeatEnd
            let day = 60 * 60 * 24
            let calendar = Calendar.current
            let pattern = repeatWeek.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            var index = (calendar.component(.weekday, from: nextEndDate) - 1) % 7
            if repeatOption == .everyWeek {
                while !pattern[index] {
                    nextStartDate = nextStartDate.addingTimeInterval(TimeInterval(day))
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                    index = (index + 1) % 7
                }

                (repeatStart, repeatEnd) = (nextStartDate, nextEndDate)
            } else if repeatOption == .everySecondWeek {
                if index == 0 {
                    nextStartDate = nextStartDate.addingTimeInterval(TimeInterval(day * 7))
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                }

                while !pattern[index] {
                    nextStartDate = nextStartDate.addingTimeInterval(TimeInterval(day))
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                    index = (index + 1) % 7

                    if index == 0 {
                        nextStartDate = nextStartDate.addingTimeInterval(TimeInterval(day * 7))
                        nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                    }
                }

                (repeatStart, repeatEnd) = (nextStartDate, nextEndDate)
            }
        }
    }

    @Published var repeatMonth: [Day] = (1 ... 31).map { Day(content: "\($0)") } {
        didSet {
            if mode == .edit {
                return
            }

            var nextStartDate = repeatStart
            var nextEndDate = repeatEnd
            let day = 60 * 60 * 24
            let calendar = Calendar.current
            let pattern = repeatMonth.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            let year = calendar.component(.year, from: nextEndDate)
            let month = calendar.component(.month, from: nextEndDate)

            let dateComponents = DateComponents(year: year, month: month)
            guard let dateInMonth = calendar.date(from: dateComponents),
                  let range = calendar.range(of: .day, in: .month, for: dateInMonth)
            else {
                return
            }

            let upperBound = range.upperBound - 1
            var index = (calendar.component(.day, from: nextEndDate) - 1) % upperBound
            while !pattern[index] {
                nextStartDate = nextStartDate.addingTimeInterval(TimeInterval(day))
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % upperBound
            }
            
            (repeatStart, repeatEnd) = (nextStartDate, nextEndDate)
        }
    }

    @Published var repeatYear: [Day] = (1 ... 12).map { Day(content: "\($0)월") } {
        didSet {
            if mode == .edit {
                return
            }

            var nextStartDate = repeatStart
            var nextEndDate = repeatEnd
            let calendar = Calendar.current
            let pattern = repeatYear.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            var index = (calendar.component(.month, from: nextEndDate) - 1) % 12
            while !pattern[index] {
                if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                    nextStartDate = next
                    nextEndDate = next
                    index = (index + 1) % 12
                } else {
                    return
                }
            }

            (repeatStart, repeatEnd) = (nextStartDate, nextEndDate)
        }
    }

    @Published var isSelectedRepeatEnd: Bool = false
    
    var selectedRepeatEnd: Date? {
        if isSelectedRepeat { return repeatEnd }
        return nil
    }

    var repeatValue: String? {
        // TODO: 연속된 반복인지 단일 반복인지
        if isSelectedRepeat {
            var value: [Day] = []
            switch repeatOption {
            case .everyDay:
                return repeatDay
            case .everyWeek, .everySecondWeek:
                value = repeatWeek
            case .everyMonth:
                value = repeatMonth
            case .everyYear:
                value = repeatYear
            }
            return value.reduce("") { $0 + ($1.isClicked ? "1" : "0") }
        }
        return nil
    }
    
    @Published var selectionCategory: Int? // 선택한 카테고리의 인덱스 번호
    
    var selectedAlarm: [Date] {
        var result = [Date]()
        if isSelectedAlarm {
            for i in selectIdxList.indices {
                if selectIdxList[i] {
                    switch i {
                    case 0:
                        result.append(repeatStart)
                    case 1:
                        result.append(Calendar.current.date(byAdding: .minute, value: -10, to: repeatStart) ?? repeatStart)
                    case 2:
                        result.append(Calendar.current.date(byAdding: .hour, value: -1, to: repeatStart) ?? repeatStart)
                    case 3:
                        result.append(Calendar.current.date(byAdding: .day, value: -1, to: repeatStart) ?? repeatStart)
                    default:
                        continue
                    }
                }
            }
        }
        return result
    }
    
    var categoryList: [Category] {
        calendarVM.categoryList
    }
    
    // MARK: - DI

    private var calendarVM: CalendarViewModel
    private var scheduleService: ScheduleService = .init()

    // MARK: init

    // add 시 scheduleVM 생성자
    init(calendarVM: CalendarViewModel) {
        self.calendarVM = calendarVM
        
        let selectionList = calendarVM.selectionSet.sorted(by: <)
        self.repeatStart = selectionList.first?.date ?? Date()
        self.repeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        self.realRepeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        
        self.mode = .add
        
        self.tmpRepeatStart = selectionList.first?.date ?? Date()
        self.tmpRepeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        self.tmpRepeatOption = nil
        self.tmpRepeatValue = nil
        self.tmpIsSelectedRepeatEnd = false
        self.tmpRealRepeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
    }
    
    // 수정 시 scheduleVM 생성자
    init(calendarVM: CalendarViewModel, schedule: Schedule) {
        self.calendarVM = calendarVM
        self.mode = .edit
        
        self.scheduleId = schedule.id
        
        self.repeatStart = schedule.repeatStart
        self.repeatEnd = schedule.repeatEnd
        self.realRepeatStart = schedule.realRepeatStart != nil ? schedule.realRepeatStart : schedule.repeatStart
        self.realRepeatEnd = schedule.realRepeatEnd != nil ? schedule.realRepeatEnd! : schedule.repeatEnd
        
        self.tmpRepeatStart = schedule.repeatStart
        self.tmpRepeatEnd = schedule.repeatEnd
        self.tmpRepeatOption = schedule.repeatOption
        self.tmpRepeatValue = schedule.repeatValue
        self.tmpIsSelectedRepeatEnd = schedule.repeatOption != nil ? true : false
        self.tmpRealRepeatEnd = schedule.realRepeatEnd ?? schedule.repeatEnd
        
        self.prevRepeatEnd = schedule.prevRepeatEnd
        self.nextRepeatStart = schedule.nextRepeatStart
        
        self.content = schedule.content
        self.memo = schedule.memo
        
        self.isAllDay = schedule.isAllDay
        
        if let category = schedule.category {
            self.selectionCategory = categoryList.firstIndex(where: { other in
                category.id == other.id
            })
        } else {
            self.selectionCategory = nil
        }
        
        self.isSelectedAlarm = !schedule.alarms.isEmpty

        self.repeatOption = .everyDay
        if let option = RepeatOption.allCases.first(where: { $0.rawValue == schedule.repeatOption }) {
            self.repeatOption = option
        }
        
        self.isSelectedRepeat = schedule.repeatOption != nil
        self.isSelectedRepeatEnd = schedule.realRepeatEnd != nil && schedule.realRepeatEnd!.year < 2200 ? true : false
        
        self.repeatDay = isSelectedRepeat &&
            schedule.repeatOption == RepeatOption.everyDay.rawValue
            ? (schedule.repeatValue ?? "1") : "1"
        initRepeatWeek(schedule: schedule)
        initRepeatMonth(schedule: schedule)
        initRepeatYear(schedule: schedule)
    }
    
    func initRepeatWeek(schedule: Schedule) {
        if schedule.repeatOption != RepeatOption.everyWeek.rawValue,
           schedule.repeatOption != RepeatOption.everySecondWeek.rawValue
        {
            return
        }

        if let scheduleRepeatWeek = schedule.repeatValue {
            for i in repeatWeek.indices {
                repeatWeek[i].isClicked = scheduleRepeatWeek[
                    scheduleRepeatWeek.index(scheduleRepeatWeek.startIndex, offsetBy: i)
                ] == "0" ? false : true
            }
        } else {
            for i in repeatWeek.indices {
                repeatWeek[i].isClicked = false
            }
        }
    }

    func initRepeatMonth(schedule: Schedule) {
        if schedule.repeatOption != RepeatOption.everyMonth.rawValue {
            return
        }

        if let scheduleRepeatMonth = schedule.repeatValue {
            for i in repeatMonth.indices {
                repeatMonth[i].isClicked = scheduleRepeatMonth[
                    scheduleRepeatMonth.index(scheduleRepeatMonth.startIndex, offsetBy: i)
                ] == "0" ? false : true
            }
        } else {
            for i in repeatMonth.indices {
                repeatMonth[i].isClicked = false
            }
        }
    }

    func initRepeatYear(schedule: Schedule) {
        if schedule.repeatOption != RepeatOption.everyYear.rawValue {
            return
        }

        if let scheduleRepeatYear = schedule.repeatValue {
            for i in repeatYear.indices {
                repeatYear[i].isClicked = scheduleRepeatYear[
                    scheduleRepeatYear.index(scheduleRepeatYear.startIndex, offsetBy: i)
                ] == "0" ? false : true
            }
        } else {
            for i in repeatYear.indices {
                repeatYear[i].isClicked = false
            }
        }
    }
    
    func toggleDay(repeatOption: RepeatOption, index: Int) {
        switch repeatOption {
        case .everyDay:
            break
        case .everyWeek, .everySecondWeek:
            repeatWeek[index].isClicked.toggle()
        case .everyMonth:
            repeatMonth[index].isClicked.toggle()
        case .everyYear:
            repeatYear[index].isClicked.toggle()
        }
    }
    
    /**
     * Request.Schedule 만들기
     */
    func createSchedule() -> Request.Schedule {
        let calendar = Calendar.current
        var dateComponents: DateComponents

        dateComponents = calendar.dateComponents([.year, .month, .day], from: realRepeatEnd)
        dateComponents.hour = repeatEnd.hour
        dateComponents.minute = repeatEnd.minute
        
        return Request.Schedule(
            content: content,
            memo: memo,
            isAllDay: isAllDay,
            repeatStart: isSelectedRepeat ? (realRepeatStart ?? repeatStart) : repeatStart,
            repeatEnd: isSelectedRepeat ? (isSelectedRepeatEnd ? calendar.date(from: dateComponents) ?? realRepeatEnd : CalendarHelper.getInfiniteDate()) : repeatEnd,
            repeatOption: isSelectedRepeat ? repeatOption.rawValue : nil,
            repeatValue: isSelectedRepeat ? repeatValue : nil,
            categoryId: selectionCategory != nil ? categoryList[selectionCategory!].id : nil,
            alarms: selectedAlarm
        )
    }
    
    /**
     * Request.RepeatSchedule 만들기
     */
    func createRepeatSchedule(nextRepeatStart: Date? = nil, changedDate: Date? = nil, preRepeatEnd: Date? = nil) -> Request.RepeatSchedule {
        let calendar = Calendar.current
        var dateComponents: DateComponents

        dateComponents = calendar.dateComponents([.year, .month, .day], from: realRepeatEnd)
        dateComponents.hour = repeatEnd.hour
        dateComponents.minute = repeatEnd.minute
        
        return Request.RepeatSchedule(
            content: content,
            memo: memo,
            isAllDay: isAllDay,
            repeatStart: repeatStart,
            repeatEnd: isSelectedRepeat ? (isSelectedRepeatEnd ? calendar.date(from: dateComponents) ?? realRepeatEnd : CalendarHelper.getInfiniteDate()) : repeatEnd,
            repeatOption: isSelectedRepeat ? repeatOption.rawValue : nil,
            repeatValue: isSelectedRepeat ? repeatValue : nil,
            categoryId: selectionCategory != nil ? categoryList[selectionCategory!].id : nil,
            alarms: selectedAlarm,
            nextRepeatStart: nextRepeatStart,
            changedDate: changedDate,
            preRepeatEnd: preRepeatEnd
        )
    }
    
    // 일정을 수정할 때 호출하는 함수
    func initScheduleData(schedule: Schedule) {
        scheduleId = schedule.id
        
        repeatStart = schedule.repeatStart
        repeatEnd = schedule.repeatEnd
        realRepeatEnd = schedule.repeatEnd
        
        content = schedule.content
        memo = schedule.memo
        
        isAllDay = schedule.isAllDay
        
        if let category = schedule.category {
            selectionCategory = categoryList.firstIndex(where: { other in
                category.id == other.id
            })
        } else {
            selectionCategory = nil
        }
        
        isSelectedAlarm = !schedule.alarms.isEmpty
    }
    
    /**
     * 일정 추가하기
     */
    func addSchedule() {
        let schedule = createSchedule()
        
        scheduleService.addSchedule(schedule) { result in
            switch result {
            case .success:
                // TODO: 추가된 일정을 로컬에서 가지고 있을 수 있나? (반복 일정의 경우 생각해볼 것)
                self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    /**
     * 일정 간편 추가하기
     */
    func addEasySchedule(content: String, pivotDate: Date) {
        isAllDay = true
        self.content = content
        repeatStart = pivotDate
        repeatEnd = pivotDate
        let schedule = createSchedule()
        
        scheduleService.addSchedule(schedule) { result in
            switch result {
            case .success:
                // FIXME: getCurMonthSchList를 호출할 필요가 있나?
                self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                self.calendarVM.getRefreshProductivityList()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    /**
     * 일정 수정하기
     */
    func updateSchedule() {
        let schedule = createSchedule()
        
        scheduleService.updateSchedule(scheduleId: scheduleId, schedule: schedule) { result in
            switch result {
            case .success:
                // FIXME: getCurMonthSchList를 호출할 필요가 있나?
                self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                self.calendarVM.getRefreshProductivityList()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    /**
     * 반복 일정 하나만 편집하기
     */
    func updateTargetSchedule() {
        if tmpRepeatStart == realRepeatStart {
            let schedule = createRepeatSchedule(nextRepeatStart: nextRepeatStart)
            scheduleService.updateRepeatFrontSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                    self.calendarVM.getRefreshProductivityList()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else if tmpRepeatEnd == realRepeatEnd {
            let schedule = createRepeatSchedule(preRepeatEnd: prevRepeatEnd)
            scheduleService.updateRepeatBackSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                    self.calendarVM.getRefreshProductivityList()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else {
            let schedule = createRepeatSchedule(nextRepeatStart: nextRepeatStart, changedDate: repeatStart)
            scheduleService.updateRepeatMiddleSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                    self.calendarVM.getRefreshProductivityList()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        }
    }
    
    /**
     * 일정 삭제하기
     */
    func deleteSchedule() {
        scheduleService.deleteSchedule(scheduleId: scheduleId) { result in
            switch result {
            case .success:
                self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                self.calendarVM.getRefreshProductivityList()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    /**
     * 반복 일정 하나만 삭제하기
     */
    func deleteTargetSchedule() {
        // front 호출
        if tmpRepeatStart == realRepeatStart {
            scheduleService.deleteRepeatFrontSchedule(scheduleId: scheduleId, repeatStart: nextRepeatStart ?? repeatStart) { result in
                switch result {
                case .success:
                    self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                    self.calendarVM.getRefreshProductivityList()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else if tmpRepeatEnd == realRepeatEnd {
            scheduleService.deleteRepeatBackSchedule(scheduleId: scheduleId, repeatEnd: prevRepeatEnd ?? repeatEnd) { result in
                switch result {
                case .success:
                    self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                    self.calendarVM.getRefreshProductivityList()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else {
            scheduleService.deleteRepeatMiddleSchedule(scheduleId: scheduleId, removedDate: repeatStart, repeatStart: nextRepeatStart ?? repeatStart) { result in
                switch result {
                case .success:
                    self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                    self.calendarVM.getRefreshProductivityList()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        }
    }
}
