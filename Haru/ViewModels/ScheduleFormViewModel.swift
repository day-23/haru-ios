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
    
    @Published var repeatStart: Date
    @Published var repeatEnd: Date
    
    var overWeek: Bool {
        repeatStart.distance(to: repeatEnd) > 86400.0 * 7
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
//        if isSelectedEndDate && isSelectedRepeat {
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

    init(calendarVM: CalendarViewModel, mode: ScheduleFormMode = .add) {
        self.calendarVM = calendarVM
        let selectionList = calendarVM.selectionSet.sorted(by: <)
        
        self.repeatStart = selectionList.first?.date ?? Date()
        self.repeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        
        self.mode = mode
        print("scheduleVM init")
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
        Request.Schedule(
            content: content,
            memo: memo,
            isAllDay: isAllDay,
            repeatStart: repeatStart,
            repeatEnd: repeatEnd,
            repeatOption: repeatOption.rawValue,
            repeatValue: repeatValue,
            categoryId: selectionCategory != nil ? categoryList[selectionCategory!].id : nil,
            alarms: selectedAlarm
        )
    }
    
    // 일정을 수정할 때 호출하는 함수
    func initScheduleData(schedule: Schedule) {
        scheduleId = schedule.id
        
        repeatStart = schedule.repeatStart
        repeatEnd = schedule.repeatEnd
        
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
        
        schedule.alarms.forEach { alarm in
            if alarm.time == repeatStart {
                selectIdxList[0] = true
            } else if alarm.time == Calendar.current.date(byAdding: .minute, value: -10, to: repeatStart) {
                selectIdxList[1] = true
            } else if alarm.time == Calendar.current.date(byAdding: .hour, value: -1, to: repeatStart) {
                selectIdxList[2] = true
            } else if alarm.time == Calendar.current.date(byAdding: .day, value: -1, to: repeatStart) {
                selectIdxList[3] = true
            }
        }
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
}
