//
//  Request.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//  Updated by 이준호 on 2023/03/14
//
import Foundation
import UIKit

struct Request: Codable {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    struct Todo: Codable {
        // MARK: - Request.Todo, Properties

        var content: String
        var memo: String
        var todayTodo: Bool
        var flag: Bool
        var endDate: Date?
        var isAllDay: Bool
        var alarms: [Date]
        var repeatOption: String?
        var repeatValue: String?
        var repeatEnd: Date?
        var tags: [String]
        var subTodos: [String]
        var subTodosCompleted: [Bool]?

        var dictionary: [String: Any] {
            [
                "content": self.content,
                "memo": self.memo,
                "todayTodo": self.todayTodo,
                "flag": self.flag,
                "endDate": self.endDate != nil ? Request.formatter.string(from: self.endDate!) : Date?.none as Any,
                "isAllDay": self.isAllDay,
                "alarms": self.alarms.map { Request.formatter.string(from: $0) },
                "repeatOption": self.repeatOption as Any,
                "repeatValue": self.repeatValue as Any,
                "repeatEnd": self.repeatEnd != nil ? Request.formatter.string(from: self.repeatEnd!) : Date?.none as Any,
                "tags": self.tags,
                "subTodos": self.subTodos,
                "subTodosCompleted": self.subTodosCompleted as Any
            ]
        }
    }

    struct Schedule: Codable {
        var content: String
        var memo: String
        var isAllDay: Bool
        var repeatStart: Date
        var repeatEnd: Date
        var repeatOption: String?
        var repeatValue: String?
        var categoryId: String?
        var alarms: [Date]

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Request.Schedule.CodingKeys.self)
            try container.encode(self.content, forKey: Request.Schedule.CodingKeys.content)
            try container.encode(self.memo, forKey: Request.Schedule.CodingKeys.memo)
            try container.encode(self.isAllDay, forKey: Request.Schedule.CodingKeys.isAllDay)
            try container.encode(self.repeatStart, forKey: Request.Schedule.CodingKeys.repeatStart)
            try container.encode(self.repeatEnd, forKey: Request.Schedule.CodingKeys.repeatEnd)
            try container.encode(self.repeatOption, forKey: Request.Schedule.CodingKeys.repeatOption)
            try container.encode(self.repeatValue, forKey: Request.Schedule.CodingKeys.repeatValue)
            try container.encode(self.categoryId, forKey: Request.Schedule.CodingKeys.categoryId)
            try container.encode(self.alarms, forKey: Request.Schedule.CodingKeys.alarms)
        }
    }

    struct RepeatSchedule: Codable {
        var content: String
        var memo: String
        var isAllDay: Bool
        var repeatStart: Date
        var repeatEnd: Date
        var repeatOption: String?
        var repeatValue: String?
        var categoryId: String?
        var alarms: [Date]
        var nextRepeatStart: Date?
        var changedDate: Date?
        var preRepeatEnd: Date?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Request.RepeatSchedule.CodingKeys.self)
            try container.encode(self.content, forKey: Request.RepeatSchedule.CodingKeys.content)
            try container.encode(self.memo, forKey: Request.RepeatSchedule.CodingKeys.memo)
            try container.encode(self.isAllDay, forKey: Request.RepeatSchedule.CodingKeys.isAllDay)
            try container.encode(self.repeatStart, forKey: Request.RepeatSchedule.CodingKeys.repeatStart)
            try container.encode(self.repeatEnd, forKey: Request.RepeatSchedule.CodingKeys.repeatEnd)
            try container.encode(self.repeatOption, forKey: Request.RepeatSchedule.CodingKeys.repeatOption)
            try container.encode(self.repeatValue, forKey: Request.RepeatSchedule.CodingKeys.repeatValue)
            try container.encode(self.categoryId, forKey: Request.RepeatSchedule.CodingKeys.categoryId)
            try container.encode(self.alarms, forKey: Request.RepeatSchedule.CodingKeys.alarms)

            try container.encodeIfPresent(self.nextRepeatStart, forKey: Request.RepeatSchedule.CodingKeys.nextRepeatStart)
            try container.encodeIfPresent(self.changedDate, forKey: Request.RepeatSchedule.CodingKeys.changedDate)
            try container.encodeIfPresent(self.preRepeatEnd, forKey: Request.RepeatSchedule.CodingKeys.preRepeatEnd)
        }
    }

    struct Category: Codable {
        var content: String
        var color: String?
        var categoryOrder: Int?
    }

    struct Profile: Codable {
        var name: String
        var introduction: String
    }
}
