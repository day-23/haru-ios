//
//  Request.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
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
        var isSelectedEndDateTime: Bool
        var alarms: [Date]
        var repeatOption: String?
        var repeatValue: String?
        var repeatEnd: Date?
        var tags: [String]
        var subTodos: [String]

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Request.Todo.CodingKeys.self)
            try container.encode(self.content, forKey: Request.Todo.CodingKeys.content)
            try container.encode(self.memo, forKey: Request.Todo.CodingKeys.memo)
            try container.encode(self.todayTodo, forKey: Request.Todo.CodingKeys.todayTodo)
            try container.encode(self.flag, forKey: Request.Todo.CodingKeys.flag)
            try container.encode(self.endDate, forKey: Request.Todo.CodingKeys.endDate)
            try container.encode(self.isSelectedEndDateTime, forKey: Request.Todo.CodingKeys.isSelectedEndDateTime)
            try container.encode(self.alarms, forKey: Request.Todo.CodingKeys.alarms)
            try container.encode(self.repeatOption, forKey: Request.Todo.CodingKeys.repeatOption)
            try container.encode(self.repeatValue, forKey: Request.Todo.CodingKeys.repeatValue)
            try container.encode(self.repeatEnd, forKey: Request.Todo.CodingKeys.repeatEnd)
            try container.encode(self.tags, forKey: Request.Todo.CodingKeys.tags)
            try container.encode(self.subTodos, forKey: Request.Todo.CodingKeys.subTodos)
        }
    }
}
