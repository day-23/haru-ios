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
        var repeatOption: String?
        var `repeat`: String?
        var tags: [String]
    }
}
