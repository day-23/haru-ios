//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

final class CheckListViewModel: ObservableObject {
    private let service: TodoService
    @Published var todoList: [Todo] = []
    @Published var tagList: [Tag] = []

    init(service: TodoService) {
        self.service = service
    }

    func addTodo() {}
}
