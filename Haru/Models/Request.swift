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
        var content: String
        var memo: String
        var todayTodo: Bool
        var flag: Bool
        var endDate: Date?
        var endDateTime: Date?
        var alarms: [Date]
        var repeatOption: String?
        var repeatEnd: Date?
        var `repeat`: String?
        var tags: [String]
        var subTodos: [String]
    }

    struct Schedule: Codable {
        var content: String
        var memo: String
        var categoryId: String?
        var alarms: [Date]
        var flag: Bool
        var repeatOption: String?
        var repeatStart: Date
        var repeatEnd: Date
        
        var timeOption: Bool
        
        var repeatWeek: String?
        var repeatMonth: String?
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Request.Schedule.CodingKeys.self)
            try container.encode(self.content, forKey: Request.Schedule.CodingKeys.content)
            try container.encode(self.memo, forKey: Request.Schedule.CodingKeys.memo)
            try container.encode(self.categoryId, forKey: Request.Schedule.CodingKeys.categoryId)
            try container.encode(self.alarms, forKey: Request.Schedule.CodingKeys.alarms)
            try container.encode(self.flag, forKey: Request.Schedule.CodingKeys.flag)
            try container.encode(self.repeatOption, forKey: Request.Schedule.CodingKeys.repeatOption)
            try container.encode(self.repeatStart, forKey: Request.Schedule.CodingKeys.repeatStart)
            try container.encode(self.repeatEnd, forKey: Request.Schedule.CodingKeys.repeatEnd)
            try container.encode(self.timeOption, forKey: Request.Schedule.CodingKeys.timeOption)
            try container.encode(self.repeatWeek, forKey: Request.Schedule.CodingKeys.repeatWeek)
            try container.encode(self.repeatMonth, forKey: Request.Schedule.CodingKeys.repeatMonth)
        }
    }
    
    struct Category: Codable {
        var content: String
        var color: String?
    }
}
