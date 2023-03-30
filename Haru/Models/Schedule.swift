//
//  Schedule.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

struct Schedule: Identifiable, Codable {
    let id: String
    private(set) var content: String // 일정 제목
    private(set) var memo: String
    private(set) var isAllDay: Bool
    private(set) var repeatOption: String?
    private(set) var repeatValue: String?
    private(set) var repeatStart: Date
    private(set) var repeatEnd: Date

    private(set) var category: Category?

    private(set) var alarms: [Alarm]

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date?
    private(set) var deletedAt: Date?
}

// MARK: - extension

extension Schedule: Productivity, Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id
    }

    mutating func setRepeatStart(_ newer: Date) {
        repeatStart = newer
    }

    mutating func setRepeatEnd(_ newer: Date) {
        repeatEnd = newer
    }
}
