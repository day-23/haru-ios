//
//  Schedule.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//  Updated by 최정민 on 2023/03/31.
//

import Foundation

struct Schedule: Identifiable, Codable {
    let id: String
    var content: String // 일정 제목
    var memo: String
    var isAllDay: Bool

    var repeatStart: Date
    var repeatEnd: Date

    var repeatOption: String?
    var repeatValue: String?

    var category: Category?

    var alarms: [Alarm]

    // MARK: - Dates

    let createdAt: Date?
    var updatedAt: Date?

    // MARK: 프론트를 위한 필드

    var realRepeatStart: Date?
    var realRepeatEnd: Date?

    var prevRepeatEnd: Date?
    var nextRepeatEnd: Date?
}

// MARK: - extension

extension Schedule: Productivity, Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id && lhs.repeatStart == rhs.repeatStart
    }
}

extension Schedule {
    static func createRepeatSchedule(schedule: Schedule, repeatStart: Date, repeatEnd: Date, prevRepeatEnd: Date?, nextRepeatEnd: Date?) -> Schedule {
        Schedule(
            id: schedule.id,
            content: schedule.content,
            memo: schedule.memo,
            isAllDay: schedule.isAllDay,
            repeatStart: repeatStart,
            repeatEnd: repeatEnd,
            repeatOption: schedule.repeatOption,
            repeatValue: schedule.repeatValue,
            category: schedule.category,
            alarms: schedule.alarms,
            createdAt: schedule.createdAt,
            realRepeatStart: schedule.repeatStart,
            realRepeatEnd: schedule.repeatEnd,
            prevRepeatEnd: prevRepeatEnd,
            nextRepeatEnd: nextRepeatEnd
        )
    }
}
