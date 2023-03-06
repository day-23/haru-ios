//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

final class CheckListViewModel: ObservableObject {
    @Published var todoList: [Todo] = [
        Todo(id: "1", content: "Todo 1", memo: "Memo 1", createdAt: Date(), updatedAt: Date()),
        Todo(id: "2", content: "Todo 2", memo: "Memo 2", createdAt: Date(), updatedAt: Date()),
        Todo(id: "3", content: "Todo 3", memo: "Memo 3", createdAt: Date(), updatedAt: Date()),
        Todo(id: "4", content: "Todo 4", memo: "Memo 4", createdAt: Date(), updatedAt: Date()),
        Todo(id: "5", content: "Todo 5", memo: "Memo 5", createdAt: Date(), updatedAt: Date()),
        Todo(id: "6", content: "Todo 6", memo: "Memo 6", createdAt: Date(), updatedAt: Date()),
    ]
    @Published var tagList: [Tag] = []
    private let service: TodoService

    init(service: TodoService) {
        self.service = service
    }

    func addTodo() {}
}
