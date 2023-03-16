//
//  Request.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import Foundation

struct Request: Codable {
    struct Todo: Codable {
        var content: String
        var memo: String
        var todayTodo: Bool
        var flag: Bool
        var endDate: Date?
        var endDateTime: Date?
        var alarms: [Date]
        var repeatOption: String?
        var repeatEnd: Date?
        var repeatWeek: String?
        var repeatMonth: String?
        var repeatYear: String?
        var tags: [String]
        var subTodos: [String]

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.content, forKey: .content)
            try container.encode(self.memo, forKey: .memo)
            try container.encode(self.todayTodo, forKey: .todayTodo)
            try container.encode(self.flag, forKey: .flag)
            try container.encode(self.endDate, forKey: .endDate)
            try container.encode(self.endDateTime, forKey: .endDateTime)
            try container.encode(self.alarms, forKey: .alarms)
            try container.encode(self.repeatOption, forKey: .repeatOption)
            try container.encode(self.repeatEnd, forKey: .repeatEnd)
            try container.encode(self.repeatWeek, forKey: .repeatWeek)
            try container.encode(self.repeatMonth, forKey: .repeatMonth)
            try container.encode(self.repeatYear, forKey: .repeatYear)
            try container.encode(self.tags, forKey: .tags)
            try container.encode(self.subTodos, forKey: .subTodos)
        }
    }
}
