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
    private(set) var `repeat`: String?
    private(set) var endDate: Date?
    private(set) var endDateTime: Date?
    private(set) var subTodos: [SubTodo]

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date
    private(set) var deletedAt: Date?
}

// MARK: - Extensions

extension Todo {
    mutating func setContent(_ content: String) {
        self.content = content
        self.updatedAt = Date()
    }

    mutating func setMemo(_ memo: String) -> Bool {
        if memo.count > 500 {
            return false
        }
        self.memo = memo
        self.updatedAt = Date()
        return true
    }

    mutating func setTodayTodo(_ isTodayTodo: Bool) {
        self.todayTodo = isTodayTodo
        self.updatedAt = Date()
    }

    mutating func setFlag(_ flag: Bool) {
        self.flag = flag
        self.updatedAt = Date()
    }

    mutating func setRepeatOption(_ repeatOption: String) {
        self.repeatOption = repeatOption
        self.updatedAt = Date()
    }

    mutating func setRepeat(_ repeat: String) {
        self.repeat = `repeat`
        self.updatedAt = Date()
    }
}
