//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Alamofire
import Foundation
import SwiftUI

final class CheckListViewModel: ObservableObject {
    // MARK: - enums

    enum Mode {
        case main
        case tag
        case haru
    }

    // MARK: - Properties

    @StateObject var todoState: TodoState
    init(todoState: StateObject<TodoState>) {
        _todoState = todoState
    }

    private let tagService: TagService = .init()
    var mode: CheckListViewModel.Mode = .main

    @Published var tagContent: String = ""
    @Published var selectedTag: Tag? = nil {
        didSet {
            if let tag = selectedTag {
                if tag.id != "하루"
                    && tag.id != "중요"
                    && tag.id != "미분류"
                    && tag.id != "완료"
                {
                    fetchTodoListByTag(tag: tag)
                    mode = .tag
                } else {
                    mode = .main
                }
            } else {
                mode = .main
            }
        }
    }

    @Published var tagList: [Tag] = []

    // add or update로 변경된 TodoId
    @Published var justAddedTodoId: String?

    // 현재 보여지고 있는 todoList의 offset
    @Published var todoListOffsetMap: [String: CGFloat] = [:]

    var isEmpty: Bool {
        return (todoState.todoListByTag.isEmpty
            && todoState.todoListByFlag.isEmpty
            && todoState.todoListByCompleted.isEmpty
            && todoState.todoListByFlagWithToday.isEmpty
            && todoState.todoListByTodayTodo.isEmpty
            && todoState.todoListByUntilToday.isEmpty
            && todoState.todoListWithAnyTag.isEmpty
            && todoState.todoListWithoutTag.isEmpty)
    }

    // MARK: - Create

    func addTag(
        content: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        tagService.createTag(content: content) { result in
            switch result {
            case .success:
                self.fetchTags()
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func addTodo(
        todo: Request.Todo,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        todoState.addTodo(todo: todo) { result in
            switch result {
            case let .success(addedTodo):
                completion(.success(addedTodo))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Read

    func fetchTags() {
        tagService.fetchTags { result in
            switch result {
            case let .success(tagList):
                withAnimation {
                    self.tagList = tagList
                }
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTodoList() {
        switch mode {
        case .main:
            todoState.fetchAllTodoList()
        case .tag:
            if let selectedTag = selectedTag {
                fetchTodoListByTag(tag: selectedTag)
            }
        case .haru:
            todoState.fetchTodoListByTodayTodoAndUntilToday()
        }
    }

    func fetchTodoListByTag(tag: Tag) {
        if tag.id == DefaultTag.important.rawValue {
            todoState.fetchTodoListByFlag()
        } else if tag.id == DefaultTag.unclassified.rawValue {
            todoState.fetchTodoListWithoutTag()
        } else if tag.id == DefaultTag.completed.rawValue {
            // FIXME: - 페이지네이션 함수로 호출 해야함
            todoState.fetchTodoListByCompletedInMain()
        } else if tag.id == DefaultTag.haru.rawValue {
            todoState.fetchTodoListByTodayTodoAndUntilToday()
        } else {
            todoState.fetchTodoListByTag(tag: tag)
        }
    }

    // MARK: - Update

    func updateTodo(
        todoId: String,
        todo: Request.Todo
    ) {
        todoState.updateTodo(todoId: todoId,
                             todo: todo) { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        }
    }

    func updateTodoWithRepeat(
        todoId: String,
        todo: Request.Todo,
        date: Date,
        at: RepeatAt
    ) {
        todoState.updateTodoWithRepeat(
            todoId: todoId,
            todo: todo,
            date: date,
            at: at
        ) { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        }
    }

    func updateFlag(
        todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoState.updateFlag(todo: todo) { result in
            switch result {
            case let .success(success):
                self.fetchTodoList()
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateFolded(
        todo: Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoState.updateFolded(todo: todo) { result in
            switch result {
            case let .success(success):
                self.fetchTodoList()
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func completeTodo(
        todoId: String,
        completed: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoState.completeTodo(
            todoId: todoId,
            completed: completed
        ) { result in
            switch result {
            case let .success(success):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fetchTodoList()
                }
                completion(.success(success))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func completeSubTodo(
        subTodoId: String,
        completed: Bool
    ) {
        todoState.completeSubTodo(subTodoId: subTodoId,
                                  completed: completed) { result in
            switch result {
            case .success:
                self.fetchTodoList()
            case .failure:
                break
            }
        }
    }

    func completeTodoWithRepeat(
        todo: Todo,
        nextEndDate: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoState.completeTodoWithRepeat(
            todo: todo,
            nextEndDate: nextEndDate,
            at: at
        ) { result in
            switch result {
            case let .success(success):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fetchTodoList()
                }
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func toggleVisibility(
        tagId: String,
        isSeleted: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let params: Parameters = [
            "isSelected": !isSeleted
        ]

        tagService.updateTag(
            tagId: tagId,
            params: params
        ) { result in
            switch result {
            case .success:
                self.fetchTags()
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateTag(
        tagId: String,
        params: Parameters,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        tagService.updateTag(
            tagId: tagId,
            params: params
        ) { result in
            switch result {
            case .success:
                self.fetchTags()
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Delete

    func deleteTodo(
        todoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoState.deleteTodo(todoId: todoId) { result in
            switch result {
            case let .success(success):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    self.fetchTodoList()
                    completion(.success(success))
                }
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
        todoState.deleteTodoWithRepeat(
            todoId: todoId,
            date: date,
            at: at
        ) { result in
            switch result {
            case let .success(success):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    self.fetchTodoList()
                    completion(.success(success))
                }
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
        todoState.deleteSubTodo(todoId: todoId, subTodoId: subTodoId) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteTag(
        tagId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        tagService.deleteTag(tagId: tagId) { result in
            switch result {
            case .success:
                self.fetchTodoList()
                self.fetchTags()
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
