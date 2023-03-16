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
    }
}
