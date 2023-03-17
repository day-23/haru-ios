//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation
import SwiftUI

final class CheckListViewModel: ObservableObject {
    // MARK: - Properties

    private let todoService: TodoService = .init()
    private let tagService: TagService = .init()
    @Published var todoList: [Todo] = []
    @Published var tagList: [Tag] = []
    @Published var selectedTag: Tag? = nil

    // MARK: - Methods

    func fetchTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        tagService.fetchTags { result in
            switch result {
            case let .success(tagList):
                self.tagList = tagList
                completion(.success(tagList))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func addTodo(
        _ todo: Request.Todo,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        todoService.addTodo(todo) { result in
            switch result {
            case let .success(todo):
                self.todoList.insert(
                    Todo(id: todo.id,
                         content: todo.content,
                         memo: todo.memo,
                         todayTodo: todo.todayTodo,
                         flag: todo.flag,
                         repeatOption: todo.repeatOption,
                         repeatWeek: todo.repeatWeek,
                         alarms: todo.alarms,
                         endDate: todo.endDate,
                         endDateTime: todo.endDateTime,
                         todoOrder: todo.todoOrder,
                         completed: todo.completed,
                         subTodos: todo.subTodos,
                         tags: todo.tags,
                         createdAt: Date()),
                    at: 0
                )
                completion(.success(todo))
            case let .failure(error):
                print(
                    "[Debug] \(error) (\(#fileID), \(#function))"
                )
                completion(.failure(error))
            }
        }
    }

    func fetchTodoList(completion: @escaping (Result<[Todo], Error>) -> Void) {
        todoService.fetchTodoList { result in
            switch result {
            case let .success(todoList):
                withAnimation {
                    self.todoList = todoList
                }
                completion(.success(todoList))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func fetchTodayTodoList(completion _: @escaping (Result<[Todo], Error>) -> Void) {}

    func fetchTodoListWithAnyTag() {}

    func fetchTodoListWithTag(_: Tag, completion _: @escaping (Result<[Todo], Error>) -> Void) {}

    func fetchTodoListWithFlag() {}

    func fetchTodoListWithoutTag() {}

    func fetchTodoListWithCompleted() {}

    func updateTodo(
        _ todoId: String,
        _ todo: Request.Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.updateTodo(todoId, todo) { result in
            switch result {
            case .success:
                self.fetchTodoList { _ in }
                completion(.success(true))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func updateFlag(
        _ todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let index = todoList.firstIndex(where: { $0.id == todo.id })
        else {
            print("[Debug] Todo를 찾지 못했습니다. (\(#fileID), \(#function))")
            return
        }

        todoService.updateFlag(todo.id, !todo.flag) { result in
            switch result {
            case let .success(success):
                withAnimation(.easeOut(duration: 0.25)) {
                    self.todoList[index] = Todo(
                        id: todo.id,
                        content: todo.content,
                        memo: todo.memo,
                        todayTodo: todo.todayTodo,
                        flag: !todo.flag,
                        repeatOption: todo.repeatOption,
                        repeatWeek: todo.repeatWeek,
                        alarms: todo.alarms,
                        endDate: todo.endDate,
                        endDateTime: todo.endDateTime,
                        todoOrder: todo.todoOrder,
                        completed: todo.completed,
                        subTodos: todo.subTodos,
                        tags: todo.tags,
                        createdAt: todo.createdAt,
                        updatedAt: todo.updatedAt,
                        deletedAt: todo.deletedAt
                    )
                }
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteTodo(
        _ todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteTodo(todo.id) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteSubTodo(
        _ todo: Todo,
        _ subTodo: SubTodo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteSubTodo(todo.id, subTodo.id) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - TodoList 분류하는 함수 (API 이용 fetch가 아닙니다.)

    func filterTodoByTag() -> [Todo] {
        return todoList
            .filter { $0.tags.contains { $0.id == self.selectedTag?.id } }
    }

    func filterTodoByFlag() -> [Todo] {
        return todoList.filter { $0.flag }
    }

    func filterTodoByHasAnyTag() -> [Todo] {
        return todoList.filter { !$0.tags.isEmpty && !$0.flag }
    }

    func filterTodoByWithoutTag() -> [Todo] {
        return todoList.filter { $0.tags.isEmpty && !$0.flag }
    }

    func filterTodoByTodayTodoOrTodayEndDate() -> [Todo] {
        return todoList.filter {
            $0.todayTodo || $0.endDate?
                .compare(Date.now) == .orderedAscending
        }
    }

    func filterTodoByTodayTodo() -> [Todo] {
        return todoList.filter { $0.todayTodo }
    }

    func filterTodoByTodayEndDate() -> [Todo] {
        return todoList.filter { $0.endDate?.compare(Date.now) == .orderedSame }
    }
}
