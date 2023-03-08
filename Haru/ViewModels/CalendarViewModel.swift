//
//  CalendarViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var scheduleList: [Schedule] = []
    
    init() {
        getCurMonthSchList()
    }

    private let scheduleService = ScheduleService()
    
    func getCurMonthSchList(_ currentMonth: Date = Date()) {
        scheduleList = scheduleService.fetchCurMonthScheduleList(currentMonth)
    }
}
