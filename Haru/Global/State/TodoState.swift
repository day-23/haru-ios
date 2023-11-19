//
//  TodoState.swift
//  Haru
//
//  Created by 최정민 on 2023/05/16.
//

import Foundation
import SwiftUI

final class TodoState: ObservableObject {
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
        TodoService.addTodo(todo: todo) { result in
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
        TodoService.fetchTodoListByTag(tag: tag) { result in
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
        TodoService.fetchTodoListByFlag { result in
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
        TodoService.fetchTodoListByCompletedInMain { result in
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
        TodoService.fetchTodoListByTodayTodoAndUntilToday { result in
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
        TodoService.fetchTodoListWithoutTag { result in
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
        TodoService.fetchAllTodoList { result in
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
        TodoService.updateTodo(todoId: todoId,
                               todo: todo)
        { result in
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
        TodoService.updateTodoWithRepeat(
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
        TodoService.updateFlag(todoId: todo.id,
                               flag: !todo.flag)
        { result in
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
        TodoService.updateFolded(todoId: todo.id,
                                 folded: !todo.folded)
        { result in
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
        TodoService.updateOrderMain(
            todoListByFlag: todoListByFlag,
            todoListWithAnyTag: todoListWithAnyTag,
            todoListWithoutTag: todoListWithoutTag,
            todoListByCompleted: todoListByCompleted
        )
    }

    func updateOrderHaru() {
        TodoService.updateOrderHaru(
            todoListByFlagWithToday: todoListByFlagWithToday,
            todoListByTodayTodo: todoListByTodayTodo,
            todoListByUntilToday: todoListByUntilToday
        )
    }

    func updateOrderFlag() {
        TodoService.updateOrderFlag(
            todoListByFlag: todoListByFlag
        )
    }

    func updateOrderWithoutTag() {
        TodoService.updateOrderWithoutTag(
            todoListWithoutTag: todoListWithoutTag
        )
    }

    func updateOrderByTag(tagId: String) {
        TodoService.updateOrderByTag(
            tagId: tagId,
            todoListByTag: todoListByTag
        )
    }

    func completeTodo(
        todoId: String,
        completed: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        TodoService.completeTodo(
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
        TodoService.completeSubTodo(subTodoId: subTodoId,
                                    completed: completed)
        { result in
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
        todo: Todo,
        date: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        TodoService.completeTodoWithRepeat(
            todo: todo,
            date: date,
            at: at
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
        TodoService.deleteTodo(todoId: todoId) { result in
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
        TodoService.deleteTodoWithRepeat(
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
        TodoService.deleteSubTodo(todoId: todoId, subTodoId: subTodoId) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
