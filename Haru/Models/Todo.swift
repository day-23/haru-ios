//
//  Todo.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct Todo: Identifiable, Codable {
    // MARK: - Properties

    let id: String
    private(set) var content: String
    private(set) var memo: String
    private(set) var todayTodo: Bool
    private(set) var flag: Bool
    private(set) var repeatOption: String?
    private(set) var repeatValue: String?
    private(set) var alarms: [Alarm]
    private(set) var endDate: Date?
    private(set) var endDateTime: Date?
    private(set) var repeatEnd: Date?
    private(set) var todoOrder: Int?
    private(set) var todayTodoOrder: Int?
    private(set) var nextSubTodoOrder: Int?
    private(set) var completed: Bool
    var subTodos: [SubTodo]
    private(set) var tags: [Tag]

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date?
    private(set) var deletedAt: Date?
}

// MARK: - Extensions

extension Todo {}
