//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

final class CheckListViewModel: ObservableObject {
    private let service: TodoService = .init()
    @Published var todoList: [Todo] = []
    @Published var tagList: [Tag] = [
        Tag(id: "미분류", content: "#미분류", createdAt: Date())
    ]

    func addTodo(_ todo: Request.Todo) {
        service.addTodo(User.default.userId, todo) { [weak self] statusCode in
            switch statusCode {
            case 200:
                debugPrint("[Debug]: Todo 생성 API 호출 성공")
                self?.todoList.append(
                    Todo(id: (self?.todoList.count.description)!,
                         content: todo.content,
                         memo: todo.memo,
                         createdAt: Date(),
                         updatedAt: Date())
                )
            default:
                debugPrint("[Debug]: StatusCode = \(statusCode) in CheckListViewModel.addTodo(_ todo: Request.Todo)")
            }
        }
    }
}
