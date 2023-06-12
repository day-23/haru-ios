//
//  Tab.swift
//  Haru
//
//  Created by 최정민 on 2023/05/27.
//

import SwiftUI

enum Tab: Int, CaseIterable {
    case sns
    case todo
    case calendar
    case timetable
    case my

    // MARK: Internal

    var title: String {
        switch self {
        case .sns: return "기록"
        case .calendar: return "일정"
        case .todo: return "할 일"
        case .timetable: return "주간"
        case .my: return "마이"
        }
    }

    var icon: String {
        switch self {
        case .sns: return "tabview-sns"
        case .calendar: return "tabview-calendar"
        case .todo: return "tabview-todo"
        case .timetable: return "tabview-time-table"
        case .my: return "tabview-setting"
        }
    }
}
