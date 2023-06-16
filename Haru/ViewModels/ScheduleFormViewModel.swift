//
//  ScheduleFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import Foundation
import SwiftUI

final class ScheduleFormViewModel: ObservableObject {
    enum From {
        case calendar
        case timeTable
    }
    
    @State var from: From
    
    // TODO: 반복 설정, 하루종일 설정
    @Published var setRepeatTime: Bool = false
    
    // 추가 or 수정
    var oriSchedule: Schedule? // 수정시 원본 일정 데이터
    var scheduleId: String?
    var mode: ScheduleFormMode
    
    // Time Table에서 반복 일정 수정시에 필요한 데이터
    var at: RepeatAt
    
    // 초기 값
    var tmpRepeatStart: Date // 일정 시작일
    var tmpRepeatEnd: Date // 일정 종료일
    var tmpRepeatOption: RepeatOption?
    var tmpRepeatValue: String?
    var tmpIsSelectedRepeatEnd: Bool
    var tmpRealRepeatEnd: Date // 반복 일정 마감일
    
    // 반복 일정인 경우
    var realRepeatStart: Date? // 반복 일정 시작일 (반복의 첫 시작일)
    
    // 수정 시 필요한 추가 정보
    var prevRepeatEnd: Date? // 이전 반복 일정의 종료일
    var nextRepeatStart: Date? // 다음 반복 일정의 시작일
    
    var buttonDisable: Bool {
        isWarning || isFieldEmpty
    }
    
    var isFieldEmpty: Bool {
        if isSelectedRepeat {
            if !overDay {
                switch repeatOption {
                case .everyDay:
                    if repeatDay.isEmpty {
                        return true
                    }
                case .everyWeek, .everySecondWeek:
                    if repeatWeek.filter(\.isClicked).isEmpty {
                        return true
                    }
                case .everyMonth:
                    if repeatMonth.filter(\.isClicked).isEmpty {
                        return true
                    }
                case .everyYear:
                    if repeatYear.filter(\.isClicked).isEmpty {
                        return true
                    }
                }
            }
        }
        return content.isEmpty
    }
    
    @Published var isWarning: Bool = false

    @Published var repeatStart: Date {
        willSet {
            if newValue > repeatEnd {
                repeatEnd = newValue.addingTimeInterval(60 * 60)
            } else {
                isWarning = false
            }
            
            if repeatEnd - newValue < 60 * 30 {
                repeatEnd = newValue.addingTimeInterval(TimeInterval(60 * 30))
            }
        }
    }

    @Published var repeatEnd: Date {
        willSet {
            if newValue < repeatStart {
                isWarning = true
            } else {
                isWarning = false
            }
            
            if newValue - repeatStart < 60 * 30 {
                repeatStart = newValue.addingTimeInterval(-TimeInterval(60 * 30))
            }
            
            if newValue > realRepeatEnd {
                realRepeatEnd = newValue
            }
        }
    }

    @Published var realRepeatEnd: Date
    
    // 시작과 끝이 7일 이상인가
    var overWeek: Bool {
        let startDate = CalendarHelper.removeTimeData(date: repeatStart)
        let endDate = CalendarHelper.removeTimeData(date: repeatEnd)
        
        let flag = startDate.distance(to: endDate) >= 86400.0 * 7
        if flag {
            DispatchQueue.main.async {
                self.isSelectedRepeat = false
            }
        }
        
        return flag
    }
    
    // 시작과 끝이 1일 이상인가
    var overDay: Bool {
        let startDate = CalendarHelper.removeTimeData(date: repeatStart)
        let endDate = CalendarHelper.removeTimeData(date: repeatEnd)
        
        let result = startDate.distance(to: endDate) >= 86400.0
        if result, repeatOption == .everyDay {
            DispatchQueue.main.async {
                self.repeatOption = .everyWeek
            }
        }
        return result
    }
    
    // 시작과 끝이 달을 넘어가는 경우
    var overMonth: Bool {
        let flag = repeatStart.month != repeatEnd.month
        return flag
    }
    
    @Published var content: String = ""
    @Published var memo: String = ""
    
    @Published var isAllDay: Bool = false {
        willSet {
            if !newValue {
                if repeatEnd < repeatStart {
                    isWarning = true
                } else {
                    isWarning = false
                }
            } else {
                isWarning = false
            }
        }
    }

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

            var upperBound = range.upperBound - 1
            var index = (calendar.component(.day, from: nextEndDate) - 1) % upperBound
            while !pattern[index] {
                index = (index + 1) % upperBound
                let month = nextEndDate.month
                nextStartDate = nextStartDate.addingTimeInterval(TimeInterval(day))
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                if month != nextEndDate.month {
                    guard let range = calendar.range(of: .day, in: .month, for: nextEndDate) else {
                        return
                    }
                    upperBound = range.upperBound - 1
                }
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
        if isSelectedRepeat, !overDay {
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
        } else if isSelectedRepeat, overDay {
            let timeInterval = repeatEnd.timeIntervalSinceReferenceDate - repeatStart.timeIntervalSinceReferenceDate
            return "T\(timeInterval)"
        }
        return nil
    }
    
    @Published var selectionCategory: Int? // 선택한 카테고리의 인덱스 번호
    
    var selectedAlarm: [Date] {
        return isSelectedAlarm ? [.now] : []
    }
    
    // MARK: - DI

    private var scheduleService: ScheduleService = .init()
    private var successAction: () -> Void
    var categoryList: [Category]

    // MARK: init

    // add 시 scheduleVM 생성자
    init(
        selectionSet: Set<DateValue>,
        categoryList: [Category],
        successAction: @escaping () -> Void
    ) {
        let selectionList = selectionSet.sorted(by: <)
        self.repeatStart = selectionList.first?.date ?? Date()
        self.repeatEnd = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: selectionList.last?.date ?? Date()
        ) ?? Date()
        self.realRepeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        
        self.mode = .add
        
        self.tmpRepeatStart = selectionList.first?.date ?? Date()
        self.tmpRepeatEnd = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: selectionList.last?.date ?? Date()
        ) ?? Date()
        self.tmpRepeatOption = nil
        self.tmpRepeatValue = nil
        self.tmpIsSelectedRepeatEnd = false
        self.tmpRealRepeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        
        self.categoryList = categoryList
        self.successAction = successAction
        self.at = .none
        self.from = .calendar
    }
    
    // edit 시 scheduleVM 생성자
    init(
        schedule: Schedule,
        categoryList: [Category],
        at: RepeatAt = .none,
        from: From = .calendar,
        successAction: @escaping () -> Void
    ) {
        self.mode = .edit
        self.at = at
        self.from = from
        
        self.scheduleId = schedule.id
        self.oriSchedule = schedule
        
        self.repeatStart = schedule.repeatStart
        self.repeatEnd = schedule.repeatEnd
        self.realRepeatStart = schedule.realRepeatStart != nil ? schedule.realRepeatStart : schedule.repeatStart
        if let realRepeatEnd = schedule.realRepeatEnd, realRepeatEnd.year < 2200 {
            self.realRepeatEnd = realRepeatEnd
        } else {
            self.realRepeatEnd = schedule.repeatEnd
        }
        
        self.tmpRepeatStart = schedule.repeatStart
        self.tmpRepeatEnd = schedule.repeatEnd
        self.tmpRepeatOption = schedule.repeatOption
        self.tmpRepeatValue = schedule.repeatValue
        self.tmpIsSelectedRepeatEnd = schedule.realRepeatEnd != nil && schedule.realRepeatEnd!.year < 2200 ? true : false
        
        self.tmpRealRepeatEnd = schedule.realRepeatEnd ?? schedule.repeatEnd
        
        if from == .calendar {
            self.prevRepeatEnd = schedule.prevRepeatEnd
            self.nextRepeatStart = schedule.nextRepeatStart
        } else {
            do {
                self.prevRepeatEnd = try schedule.prevRepeatEndDate(curRepeatEnd: schedule.repeatEnd)
                self.nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: schedule.repeatStart)
            } catch {}
        }
        
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

        if let option = RepeatOption.allCases.first(where: { $0 == schedule.repeatOption }) {
            self.repeatOption = option
        }
        
        self.isSelectedRepeat = schedule.repeatOption != nil
        self.isSelectedRepeatEnd = schedule.realRepeatEnd != nil && schedule.realRepeatEnd!.year < 2200 ? true : false
        
        self.categoryList = categoryList
        self.successAction = successAction
        
        self.repeatDay = isSelectedRepeat &&
            schedule.repeatOption == .everyDay
            ? (schedule.repeatValue ?? "1") : "1"
        
        if schedule.repeatValue?.first != "T" {
            initRepeatWeek(schedule: schedule)
            initRepeatMonth(schedule: schedule)
            initRepeatYear(schedule: schedule)
        }
    }
    
    func initRepeatWeek(schedule: Schedule) {
        if schedule.repeatOption != .everyWeek,
           schedule.repeatOption != .everySecondWeek
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
        if schedule.repeatOption != .everyMonth {
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
        if schedule.repeatOption != .everyYear {
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
        dateComponents.second = repeatEnd.second
        
        var reqRepStart: Date = repeatStart // Request.Schedule의 repeatStart에 들어갈 값
        if let repeatValue, repeatValue.first != "T" {
            let pattern = repeatValue.map { $0 == "0" ? false : true }
            
            let compValue = CalendarHelper.nextRepeatStartDate(
                curDate: reqRepStart,
                pattern: pattern,
                repeatOption: repeatOption
            )
            
            if reqRepStart != compValue {
                reqRepStart = compValue
            }
        }
        
        if mode == .add { // 일정 추가
            return Request.Schedule(
                content: content,
                memo: memo,
                isAllDay: isAllDay,
                repeatStart: reqRepStart,
                repeatEnd: isSelectedRepeat ?
                    (isSelectedRepeatEnd ?
                        calendar.date(from: dateComponents) ?? realRepeatEnd
                        :
                        CalendarHelper.getInfiniteDate(repeatEnd)
                    )
                    : repeatEnd,
                repeatOption: isSelectedRepeat ? repeatOption : nil,
                repeatValue: isSelectedRepeat ? repeatValue : nil,
                categoryId: selectionCategory != nil ? categoryList[selectionCategory!].id : nil,
                alarms: selectedAlarm
            )
        } else { // 반복이 아닌 일정 수정 혹은 반복 일정 중 "모든 일정 수정" 시
            return Request.Schedule(
                content: content,
                memo: memo,
                isAllDay: isAllDay,
                repeatStart: isSelectedRepeat ? reqRepStart : repeatStart,
                repeatEnd: isSelectedRepeat ?
                    (isSelectedRepeatEnd ?
                        calendar.date(from: dateComponents) ?? realRepeatEnd
                        :
                        CalendarHelper.getInfiniteDate(repeatEnd)
                    )
                    : repeatEnd,
                repeatOption: isSelectedRepeat ? repeatOption : nil,
                repeatValue: isSelectedRepeat ? repeatValue : nil,
                categoryId: selectionCategory != nil ? categoryList[selectionCategory!].id : nil,
                alarms: selectedAlarm
            )
        }
    }
    
    /**
     * Request.RepeatSchedule 만들기 (반복 일정 중 "이 일정만 수정" 혹은 "이 일정부터 수정" 시에 호출됨)
     */
    func createRepeatSchedule(
        nextRepeatStart: Date? = nil,
        changedDate: Date? = nil,
        preRepeatEnd: Date? = nil
    ) -> Request.RepeatSchedule {
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
            repeatEnd: isSelectedRepeat ?
                (isSelectedRepeatEnd ?
                    calendar.date(from: dateComponents) ?? realRepeatEnd
                    : CalendarHelper.getInfiniteDate(repeatEnd))
                : repeatEnd,
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
                self.successAction()
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
                self.successAction()
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
                self.successAction()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    /**
     * 반복 일정 하나만 편집하기
     */
    func updateTargetSchedule(isAfter: Bool = false) {
        if (from == .calendar && oriSchedule?.at == .front)
            || (from == .timeTable && at == .front)
        {
            let schedule = createRepeatSchedule(nextRepeatStart: nextRepeatStart)
            scheduleService.updateRepeatFrontSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else if isAfter ||
            (from == .calendar && oriSchedule?.at == .back) ||
            (from == .timeTable && at == .back)
        {
            let schedule = createRepeatSchedule(preRepeatEnd: prevRepeatEnd)
            scheduleService.updateRepeatBackSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else if (from == .calendar && oriSchedule?.at == .middle) ||
            (from == .timeTable && at == .middle)
        {
            let schedule = createRepeatSchedule(nextRepeatStart: nextRepeatStart, changedDate: tmpRepeatStart)
            scheduleService.updateRepeatMiddleSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else {
            let schedule = createSchedule()
            scheduleService.updateSchedule(scheduleId: scheduleId, schedule: schedule) { result in
                switch result {
                case .success:
                    // FIXME: getCurMonthSchList를 호출할 필요가 있나?
                    self.successAction()
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
        scheduleService.deleteSchedule(scheduleId: scheduleId ?? "unknown") { result in
            switch result {
            case .success:
                self.successAction()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    /**
     * 반복 일정 하나만 삭제하기
     */
    func deleteTargetSchedule(isAfter: Bool = false) {
        // front 호출
        if oriSchedule?.at == .front || at == .front {
            scheduleService.deleteRepeatFrontSchedule(scheduleId: scheduleId ?? "unknown", repeatStart: nextRepeatStart ?? repeatStart) { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else if isAfter ||
            oriSchedule?.at == .back ||
            at == .back
        {
            scheduleService.deleteRepeatBackSchedule(scheduleId: scheduleId ?? "unknown", repeatEnd: prevRepeatEnd ?? repeatEnd) { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else if oriSchedule?.at == .middle ||
            at == .middle
        {
            scheduleService.deleteRepeatMiddleSchedule(scheduleId: scheduleId ?? "unknown", removedDate: repeatStart, repeatStart: nextRepeatStart ?? repeatStart) { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        } else {
            scheduleService.deleteSchedule(scheduleId: scheduleId ?? "unknown") { result in
                switch result {
                case .success:
                    self.successAction()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        }
    }
}
