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
    private(set) var completed: Bool?
    var subTodos: [SubTodo]
    private(set) var tags: [Tag]

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date?
    private(set) var deletedAt: Date?

    // MARK: - Decode

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.memo, forKey: .memo)
        try container.encode(self.todayTodo, forKey: .todayTodo)
        try container.encode(self.flag, forKey: .flag)
        try container.encodeIfPresent(self.repeatOption, forKey: .repeatOption)
        try container.encodeIfPresent(self.repeatValue, forKey: .repeatValue)
        try container.encode(self.alarms, forKey: .alarms)
        try container.encodeIfPresent(self.endDate, forKey: .endDate)
        try container.encodeIfPresent(self.endDateTime, forKey: .endDateTime)
        try container.encodeIfPresent(self.repeatEnd, forKey: .repeatEnd)
        try container.encodeIfPresent(self.todoOrder, forKey: .todoOrder)
        try container.encodeIfPresent(self.completed, forKey: .completed)
        try container.encode(self.subTodos, forKey: .subTodos)
        try container.encode(self.tags, forKey: .tags)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encodeIfPresent(self.updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(self.deletedAt, forKey: .deletedAt)
    }
}

// MARK: - Extensions

extension Todo {}
