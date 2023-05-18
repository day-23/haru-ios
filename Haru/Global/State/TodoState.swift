//
//  TodoState.swift
//  Haru
//
//  Created by 최정민 on 2023/05/16.
//

import Foundation
import SwiftUI

final class TodoState: ObservableObject {
    private let todoService = TodoService()

    @Published var todoListByTag: [Todo] = []
    @Published var todoListByFlag: [Todo] = []
    @Published var todoListByCompleted: [Todo] = []
    @Published var todoListByFlagWithToday: [Todo] = []
    @Published var todoListByTodayTodo: [Todo] = []
    @Published var todoListByUntilToday: [Todo] = []
    @Published var todoListWithAnyTag: [Todo] = []
    @Published var todoListWithoutTag: [Todo] = []

    // MARK: - Create

    func addTodo(
        todo: Request.Todo,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        todoService.addTodo(todo: todo) { result in
            switch result {
            case let .success(addedTodo):
                completion(.success(addedTodo))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Read

    func fetchTodoListByTag(
        tag: Tag
    ) {
        todoService.fetchTodoListByTag(tag: tag) { result in
            switch result {
            case let .success(response):
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListByFlag = response.flaggedTodos
                    self.todoListByTag = response.unFlaggedTodos
                    self.todoListByCompleted = response.completedTodos
                }
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTodoListByFlag() {
        todoService.fetchTodoListByFlag { result in
            switch result {
            case let .success(success):
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListByFlag = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTodoListByCompletedInMain() {
        todoService.fetchTodoListByCompletedInMain { result in
            switch result {
            case let .success(success):
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListByCompleted = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTodoListByTodayTodoAndUntilToday() {
        todoService.fetchTodoListByTodayTodoAndUntilToday { result in
            switch result {
            case let .success(success):
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListByFlagWithToday = success.flaggedTodos
                    self.todoListByTodayTodo = success.todayTodos
                    self.todoListByUntilToday = success.endDateTodos
                    self.todoListByCompleted = success.completedTodos
                }
            case let .failure(failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTodoListWithoutTag() {
        todoService.fetchTodoListWithoutTag { result in
            switch result {
            case let .success(success):
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListWithoutTag = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchAllTodoList() {
        todoService.fetchAllTodoList { result in
            switch result {
            case let .success(success):
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListByFlag = success.flaggedTodos
                    self.todoListByCompleted = success.completedTodos
                    self.todoListByFlagWithToday = success.todayFlaggedTodos
                    self.todoListByTodayTodo = success.todayTodos
                    self.todoListByUntilToday = success.endDatedTodos
                    self.todoListWithAnyTag = success.taggedTodos
                    self.todoListWithoutTag = success.untaggedTodos
                }
            case let .failure(failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // MARK: - Update

    func updateTodo(
        todoId: String,
        todo: Request.Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.updateTodo(todoId: todoId,
                               todo: todo) { result in
            switch result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func updateTodoWithRepeat(
        todoId: String,
        todo: Request.Todo,
        date: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.updateTodoWithRepeat(
            todoId: todoId,
            todo: todo,
            date: date,
            at: at
        ) { result in
            switch result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func updateFlag(
        todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.updateFlag(todoId: todo.id,
                               flag: !todo.flag) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func updateFolded(
        todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.updateFolded(todoId: todo.id,
                                 folded: !todo.folded) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func updateOrderMain() {
        todoService.updateOrderMain(
            todoListByFlag: todoListByFlag,
            todoListWithAnyTag: todoListWithAnyTag,
            todoListWithoutTag: todoListWithoutTag,
            todoListByCompleted: todoListByCompleted
        )
    }

    func updateOrderHaru() {
        todoService.updateOrderHaru(
            todoListByFlagWithToday: todoListByFlagWithToday,
            todoListByTodayTodo: todoListByTodayTodo,
            todoListByUntilToday: todoListByUntilToday
        )
    }

    func updateOrderFlag() {
        todoService.updateOrderFlag(
            todoListByFlag: todoListByFlag
        )
    }

    func updateOrderWithoutTag() {
        todoService.updateOrderWithoutTag(
            todoListWithoutTag: todoListWithoutTag
        )
    }

    func updateOrderByTag(tagId: String) {
        todoService.updateOrderByTag(
            tagId: tagId,
            todoListByTag: todoListByTag
        )
    }

    func completeTodo(
        todoId: String,
        completed: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.completeTodo(
            todoId: todoId,
            completed: completed
        ) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func completeSubTodo(
        subTodoId: String,
        completed: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.completeSubTodo(subTodoId: subTodoId,
                                    completed: completed) { result in
            switch result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func completeTodoWithRepeat(
        todoId: String,
        nextEndDate: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.completeTodoWithRepeat(
            todoId: todoId,
            nextEndDate: nextEndDate,
            at: .front
        ) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Delete

    func deleteTodo(
        todoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteTodo(todoId: todoId) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteTodoWithRepeat(
        todoId: String,
        date: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteTodoWithRepeat(
            todoId: todoId,
            date: date,
            at: at
        ) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteSubTodo(
        todoId: String,
        subTodoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteSubTodo(todoId: todoId, subTodoId: subTodoId) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
