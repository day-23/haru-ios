//
//  Request.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//  Updated by 이준호 on 2023/03/14
//
import Foundation

struct Request: Codable {
    struct Todo: Codable {
        //  MARK: - Request.Todo, Properties

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
            try container.encodeIfPresent(self.repeatOption, forKey: Request.Schedule.CodingKeys.repeatOption)
            try container.encodeIfPresent(self.repeatValue, forKey: Request.Schedule.CodingKeys.repeatValue)
            try container.encodeIfPresent(self.categoryId, forKey: Request.Schedule.CodingKeys.categoryId)
            try container.encode(self.alarms, forKey: Request.Schedule.CodingKeys.alarms)
        }
    }

    struct Category: Codable {
        var content: String
        var color: String?
        var categoryOrder: Int?
    }
}
