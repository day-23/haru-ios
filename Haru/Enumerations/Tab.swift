//
//  Tab.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

enum Tab: Int, CaseIterable {
    case sns
    case checkList
    case calendar
    case timeTable
    case setting

    var title: String {
        switch self {
        case .sns: return "SNS"
        case .calendar: return "Calendar"
        case .checkList: return "Check-List"
        case .timeTable: return "Time-Table"
        case .setting: return "Setting"
        }
    }

    var systemImageName: String {
        switch self {
        case .sns: return "paperplane"
        case .calendar: return "calendar"
        case .checkList: return "checklist"
        case .timeTable: return "calendar.day.timeline.left"
        case .setting: return "person"
        }
    }

    var view: AnyView {
        switch self {
        case .sns:
            return AnyView(Text("SNS SubView"))
        case .calendar:
            return AnyView(
                CalendarMainView()
            )
        case .checkList:
            let checkListViewModel = CheckListViewModel()
            let todoAddViewModel = TodoAddViewModel(checkListViewModel: checkListViewModel)
            return AnyView(CheckListView(
                viewModel: checkListViewModel,
                addViewModel: todoAddViewModel
            ))
        case .timeTable:
            return AnyView(
                TimeTableMainView(
                    timeTableViewModel: .init(wrappedValue: TimeTableViewModel())
                )
            )
        case .setting:
            return AnyView(Text("Setting SubView"))
        }
    }
}
