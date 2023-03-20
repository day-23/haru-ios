//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation
import SwiftUI

final class CheckListViewModel: ObservableObject {
    //  MARK: - Properties

    private let tagService: TagService = .init()
    private let todoService: TodoService = .init()

    @Published var selectedTag: Tag? = nil {
        didSet {
            if let tag = selectedTag {
                if tag.id != "하루" &&
                    tag.id != "중요" &&
                    tag.id != "미분류" &&
                    tag.id != "완료"
                {
                    fetchTodoListByTag(tag: tag)
                }
            }
        }
    }

    @Published var tagList: [Tag] = []

    @Published var todoListByTag: [Todo] = []
    @Published var todoListByFlag: [Todo] = []
    @Published var todoListByCompleted: [Todo] = []
    @Published var todoListByFlagWithToday: [Todo] = []
    @Published var todoListByTodayTodo: [Todo] = []
    @Published var todoListByUntilToday: [Todo] = []
    @Published var todoListWithAnyTag: [Todo] = []
    @Published var todoListWithoutTag: [Todo] = []

    var isEmpty: Bool {
        return (todoListByTag.isEmpty &&
            todoListByFlag.isEmpty &&
            todoListByCompleted.isEmpty &&
            todoListByFlagWithToday.isEmpty &&
            todoListByTodayTodo.isEmpty &&
            todoListByUntilToday.isEmpty &&
            todoListWithAnyTag.isEmpty &&
            todoListWithoutTag.isEmpty)
    }

    //  MARK: - Create

    func addTodo(
        todo: Request.Todo,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        todoService.addTodo(todo: todo) { result in
            switch result {
            case let .success(todo):
                self.fetchTodoList()
                completion(.success(todo))
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
                completion(.failure(error))
            }
        }
    }

    //  MARK: - Read

    func fetchTags() {
        tagService.fetchTags { result in
            switch result {
            case let .success(tagList):
                withAnimation {
                    self.tagList = tagList
                }
            case let .failure(error):
                print("[Debug]: \(error) (\(#fileID), \(#function))")
            }
        }
    }

    func fetchTodoList() {
        // FIXME: - fix to Fetch All todos API
        if let selectedTag = selectedTag {
            fetchTodoListByTag(tag: selectedTag)
        }
        fetchTodoListByFlag()
        fetchTodoListByCompletedInMain()
        fetchTodoListByTodayTodoAndUntilToday()
        fetchTodoListWithAnyTag()
        fetchTodoListWithoutTag()
    }

    func fetchTodoListByTag(tag: Tag) {
        todoService.fetchTodoListByTag(tag: tag) { result in
            switch result {
            case let .success(success):
                withAnimation {
                    self.todoListByTag = success.todos
                    self.todoListByCompleted = success.completedTodos
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    func fetchTodoListByFlag() {
        todoService.fetchTodoListByFlag { result in
            switch result {
            case let .success(success):
                withAnimation {
                    self.todoListByFlag = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    func fetchTodoListByCompletedInMain() {
        todoService.fetchTodoListByCompletedInMain { result in
            switch result {
            case let .success(success):
                withAnimation {
                    self.todoListByCompleted = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    func fetchTodoListByTodayTodoAndUntilToday() {
        todoService.fetchTodoListByTodayTodoAndUntilToday(today: .now) { result in
            switch result {
            case let .success(success):
                withAnimation {
                    self.todoListByFlagWithToday = success.flaggedTodos
                    self.todoListByTodayTodo = success.todayTodos
                    self.todoListByUntilToday = success.endDateTodos
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function)")
            }
        }
    }

    func fetchTodoListWithAnyTag() {
        todoService.fetchTodoListWithAnyTag { result in
            switch result {
            case let .success(success):
                withAnimation {
                    self.todoListWithAnyTag = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    func fetchTodoListWithoutTag() {
        todoService.fetchTodoListWithoutTag { result in
            switch result {
            case let .success(success):
                withAnimation {
                    self.todoListWithoutTag = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
            }
        }
    }

    //  MARK: - Update

    func updateTodo(
        todoId: String,
        todo: Request.Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.updateTodo(todoId: todoId,
                               todo: todo) { result in
            switch result {
            case .success:
                self.fetchTodoList()
                completion(.success(true))
            case let .failure(failure):
                completion(.failure(failure))
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
                withAnimation(.easeOut(duration: 0.25)) {
                    self.fetchTodoList()
                }
                completion(.success(success))
            case let .failure(error):
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

    // MARK: - Delete

    func deleteTodo(
        todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteTodo(todoId: todo.id) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteSubTodo(
        todo: Todo,
        subTodo: SubTodo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteSubTodo(todoId: todo.id, subTodoId: subTodo.id) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
