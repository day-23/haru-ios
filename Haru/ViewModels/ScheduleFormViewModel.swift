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
    
    @Published var repeatStart: Date
    @Published var repeatEnd: Date
    @Published var alarmDate: Date = .init()
    
    @Published var content: String = ""
    @Published var memo: String = ""
    
    @Published var isAllDay: Bool = false
    @Published var isSelectedAlarm: Bool = false
    @Published var alarmOptions: [AlarmOption] = [.start]
    @Published var repeatOption: String?
    @Published var repeatValue: String?
    
    @Published var selectionCategory: Int? // 선택한 카테고리의 인덱스 번호
    
    var scheduleId: String?
    var mode: ScheduleFormMode
    
    var selectedAlarm: [Date] {
        var result = [Date]()
        if isSelectedAlarm {
            for option in alarmOptions {
                switch option {
                case .start:
                    result.append(repeatStart)
                case .tenMinAgo:
                    result.append(Calendar.current.date(byAdding: .minute, value: -10, to: repeatStart) ?? repeatStart)
                case .oneHourAgo:
                    result.append(Calendar.current.date(byAdding: .hour, value: -1, to: repeatStart) ?? repeatStart)
                case .oneDayAgo:
                    result.append(Calendar.current.date(byAdding: .day, value: -1, to: repeatStart) ?? repeatStart)
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
            repeatOption: repeatOption,
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
        
        isAllDay = !schedule.isAllDay
        isSelectedAlarm = !schedule.alarms.isEmpty
        
        if let category = schedule.category {
            selectionCategory = categoryList.firstIndex(where: { other in
                category.id == other.id
            })
        } else {
            selectionCategory = nil
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
    func addEasySchedule() {
        isAllDay = true
        let schedule = createSchedule()
        
        scheduleService.addSchedule(schedule) { result in
            switch result {
            case .success:
                // FIXME: getCurMonthSchList를 호출할 필요가 있나?
                self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                self.calendarVM.getRefreshProductivityList()
                self.content = ""
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
