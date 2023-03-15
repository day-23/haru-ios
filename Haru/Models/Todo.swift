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
    private(set) var alarms: [Alarm]
    private(set) var endDate: Date?
    private(set) var endDateTime: Date?
    private(set) var repeatEnd: Date?
    private(set) var order: Int?
    private(set) var completed: Bool?
    var subTodos: [SubTodo]
    private(set) var tags: [Tag]

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date?
    private(set) var deletedAt: Date?
}

// MARK: - Extensions

extension Todo {
    mutating func setContent(_ content: String) {
        self.content = content
    }

    mutating func setMemo(_ memo: String) -> Bool {
        if memo.count > 500 {
            return false
        }
        self.memo = memo
        return true
    }

    mutating func setTodayTodo(_ isTodayTodo: Bool) {
        self.todayTodo = isTodayTodo
    }

    mutating func setFlag(_ flag: Bool) {
        self.flag = flag
    }

    mutating func setRepeatOption(_ repeatOption: String) {
        self.repeatOption = repeatOption
    }

    mutating func setRepeat(_ repeat: String) {
        self.repeat = `repeat`
    }

    mutating func setSubTodos(_ subTodos: [SubTodo]) {
        self.subTodos = subTodos
    }
}
