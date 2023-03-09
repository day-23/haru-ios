//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

final class CheckListViewModel: ObservableObject {
    // MARK: - Properties

    private let service: TodoService = .init()
    @Published var todoList: [Todo] = []
    @Published var tagList: [Tag] = [
        Tag(id: "미분류", content: "#미분류", createdAt: Date()),
    ]

    // MARK: - Methods

    func addTodo(_ todo: Request.Todo, completion: @escaping (_ statusCode: Int) -> Void) {
        service.addTodo(todo) { [weak self] statusCode in
            switch statusCode {
            case 201:
                self?.todoList.append(
                    Todo(id: (self?.todoList.count.description)!,
                         content: todo.content,
                         memo: todo.memo,
                         todayTodo: todo.todayTodo,
                         flag: todo.flag,
                         repeatOption: todo.repeatOption,
                         repeat: todo.repeat,
                         endDate: todo.endDate,
                         endDateTime: todo.endDateTime,
                         subTodos: todo.subTodos,
                         createdAt: Date(),
                         updatedAt: Date()))
            default:
                debugPrint("[Debug] StatusCode = \(statusCode) in CheckListViewModel.addTodo(_ todo: Request.Todo)")
            }
            completion(statusCode)
        }
    }

    func fetchTodoList(completion: @escaping (_ statusCode: Int, [Todo]) -> Void) {
        service.fetchTodoList { statusCode, todoList in
            switch statusCode {
            case 200:
                self.todoList = todoList
            case -1:
                debugPrint("[Debug] Server not running now.")
            default:
                debugPrint("[Debug] StatusCode = \(statusCode) in CheckListViewModel.fetchTodoList()")
            }
        }
    }
}
