//
//  TimeTableViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import Foundation

struct ScheduleCell: Identifiable {
    var id: String
    var date: Date
    var weight: Int
    var order: Int
}

final class TimeTableViewModel: ObservableObject {
    @Published var todoList: [Todo] = []
    @Published var scheduleList: [ScheduleCell] = []
    @Published var draggingSchedule: ScheduleCell? = nil

    var thisWeek: [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        ) else {
            return []
        }

        var datesOfWeek: [Date] = []
        for i in 0 ... 6 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            datesOfWeek.append(date)
        }
        return datesOfWeek
    }
}
