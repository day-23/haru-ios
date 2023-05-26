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

    var title: String {
        switch self {
        case .sns: return "SNS"
        case .calendar: return "CAL"
        case .todo: return "TODO"
        case .timetable: return "T.T"
        case .my: return "MY"
        }
    }

    var icon: String {
        switch self {
        case .sns: return "sns"
        case .calendar: return "calendar-tabview"
        case .todo: return "todo"
        case .timetable: return "timetable"
        case .my: return "my"
        }
    }

    var selectedIcon: String {
        switch self {
        case .sns: return "sns-gradient"
        case .calendar: return "calendar-gradient"
        case .todo: return "todo-gradient"
        case .timetable: return "timetable-gradient"
        case .my: return "my-gradient"
        }
    }
}
