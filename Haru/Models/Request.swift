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
    }
}
