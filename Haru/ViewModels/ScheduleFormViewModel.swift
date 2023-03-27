//
//  ScheduleFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import Foundation
import SwiftUI

final class ScheduleFormViewModel: ObservableObject {
    @Published var repeatStart: Date
    @Published var repeatEnd: Date
    @Published var alarmDate: Date = .init()
    
    @Published var content: String = ""
    @Published var memo: String = ""
    
    @Published var timeOption: Bool = false
    @Published var isSelectedAlarm: Bool = false
    @Published var alarmOptions: [AlarmOption] = [.start]
    @Published var repeatOption: Bool = false
    @Published var memoOption: Bool = false
    
    @Published var selectionCategory: Int? // 선택한 카테고리의 인덱스 번호
    
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
    
    private var calendarVM: CalendarViewModel
    private var scheduleService: ScheduleService = .init()
    private var categoryService: CategoryService = .init()

    init(calendarVM: CalendarViewModel) {
        self.calendarVM = calendarVM
        let selectionList = calendarVM.selectionSet.sorted(by: <)
        
        self.repeatStart = selectionList.first?.date ?? Date()
        self.repeatEnd = Calendar.current.date(byAdding: .hour, value: 1, to: selectionList.last?.date ?? Date()) ?? Date()
        
        print("scheduleVM init")
    }
    
    /**
     * 일정 추가하기
     */
    func addSchedule() {
        let schedule = Request.Schedule(content: content, memo: memo, categoryId: selectionCategory != nil ? categoryList[selectionCategory!].id : nil, alarms: selectedAlarm, flag: false, repeatStart: repeatStart, repeatEnd: repeatEnd, timeOption: timeOption)
         
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
     * 카테고리 추가하기
     */
    func addCategory(_ content: String, _ color: String?) {
        let category = Request.Category(content: content, color: color != nil ? "#" + color! : nil)
        
        calendarVM.categoryList.append(Category(id: UUID().uuidString, content: content, color: color, isSelected: true))
        let index = categoryList.endIndex - 1
        
        categoryService.addCategory(category) { result in
            switch result {
            case .success(let success):
                self.calendarVM.categoryList[index] = success
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
