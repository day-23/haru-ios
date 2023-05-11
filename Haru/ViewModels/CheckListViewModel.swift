//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation
import SwiftUI

final class CheckListViewModel: ObservableObject {
    //  MARK: - enums

    enum Mode {
        case main
        case tag
        case haru
    }

    //  MARK: - Properties

    private let tagService: TagService = .init()
    private let todoService: TodoService = .init()
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

    @Published var todoListByTag: [Todo] = []
    @Published var todoListByFlag: [Todo] = []
    @Published var todoListByCompleted: [Todo] = []
    @Published var todoListByFlagWithToday: [Todo] = []
    @Published var todoListByTodayTodo: [Todo] = []
    @Published var todoListByUntilToday: [Todo] = []
    @Published var todoListWithAnyTag: [Todo] = []
    @Published var todoListWithoutTag: [Todo] = []

    //  add or update로 변경된 TodoId
    @Published var justAddedTodoId: String?

    //  현재 보여지고 있는 todoList의 offset
    @Published var todoListOffsetMap: [String: CGFloat] = [:]

    var isEmpty: Bool {
        return (todoListByTag.isEmpty
            && todoListByFlag.isEmpty
            && todoListByCompleted.isEmpty
            && todoListByFlagWithToday.isEmpty
            && todoListByTodayTodo.isEmpty
            && todoListByUntilToday.isEmpty
            && todoListWithAnyTag.isEmpty
            && todoListWithoutTag.isEmpty)
    }

    //  MARK: - Create

    func addTodo(
        todo: Request.Todo,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        todoService.addTodo(todo: todo) { result in
            switch result {
            case let .success(addedTodo):
                self.selectedTag = nil
                self.justAddedTodoId = addedTodo.id
                self.fetchTags()
                self.fetchTodoList()
                completion(.success(addedTodo))
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
                completion(.failure(error))
            }
        }
    }

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
        switch mode {
        case .main:
            fetchAllTodoList()
        case .tag:
            if let selectedTag = selectedTag {
                fetchTodoListByTag(tag: selectedTag)
            }
        case .haru:
            fetchTodoListByTodayTodoAndUntilToday()
        }
    }

    func fetchTodoListByTag(tag: Tag) {
        if tag.id == "중요" {
            fetchTodoListByFlag()
        } else if tag.id == "미분류" {
            fetchTodoListWithoutTag()
        } else if tag.id == "완료" {
            //  FIXME: - 페이지네이션 함수로 호출 해야함
            fetchTodoListByCompletedInMain()
        } else if tag.id == "하루" {
            fetchTodoListByTodayTodoAndUntilToday()
        } else {
            todoService.fetchTodoListByTag(tag: tag) { result in
                switch result {
                case let .success(success):
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.todoListByFlag = success.flaggedTodos
                        self.todoListByTag = success.unFlaggedTodos
                        self.todoListByCompleted = success.completedTodos
                    }
                case let .failure(failure):
                    print("[Debug] \(failure) (\(#fileID), \(#function))")
                }
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
                print("[Debug] \(failure) (\(#fileID), \(#function))")
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
                print("[Debug] \(failure) (\(#fileID), \(#function))")
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
                print("[Debug] \(failure) (\(#fileID), \(#function)")
            }
        }
    }

    func fetchTodoListWithAnyTag() {
        todoService.fetchTodoListWithAnyTag { result in
            switch result {
            case let .success(success):
                withAnimation(.easeInOut(duration: 0.2)) {
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.todoListWithoutTag = success
                }
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
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
                self.justAddedTodoId = todoId
                self.fetchTodoList()
                self.fetchTags()
                completion(.success(true))
            case let .failure(failure):
                completion(.failure(failure))
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
                self.justAddedTodoId = todoId
                self.fetchTodoList()
                self.fetchTags()
                completion(.success(true))
            case let .failure(error):
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
        todoService.updateFolded(todoId: todo.id,
                                 folded: !todo.folded) { result in
            switch result {
            case let .success(success):
                self.fetchTodoList()
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

    func updateOrderHaru() {
        todoService.updateOrderHaru(
            todoListByFlagWithToday: todoListByFlagWithToday,
            todoListByTodayTodo: todoListByTodayTodo,
            todoListByUntilToday: todoListByUntilToday
        )
    }

    func updateOrderFlag() {
        todoService.updateOrderFlag(todoListByFlag: todoListByFlag)
    }

    func updateOrderWithoutTag() {
        todoService.updateOrderWithoutTag(todoListWithoutTag: todoListWithoutTag)
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
        isDetailView: Bool = false,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.completeTodo(
            todoId: todoId,
            completed: completed
        ) { result in
            switch result {
            case let .success(success):
                if !isDetailView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.fetchTodoList()
                    }
                }
                completion(.success(success))
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
                completion(.failure(failure))
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
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
                completion(.failure(failure))
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fetchTodoList()
                }
                completion(.success(success))
            case let .failure(failure):
                print("[Debug] \(failure) (\(#fileID), \(#function))")
                completion(.failure(failure))
            }
        }
    }

    // FIXME: 애니메이션 이상 작동 이유일듯 함
    func toggleCompleted(todoId: String) {
        if let index = todoListByTag.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListByTag[index].completed.toggle()
            }
            return
        }

        if let index = todoListByFlag.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListByFlag[index].completed.toggle()
            }
            return
        }

        if let index = todoListByCompleted.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListByCompleted[index].completed.toggle()
            }
            return
        }

        if let index = todoListByFlagWithToday.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListByFlagWithToday[index].completed.toggle()
            }
            return
        }

        if let index = todoListByTodayTodo.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListByTodayTodo[index].completed.toggle()
            }
            return
        }

        if let index = todoListByUntilToday.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListByUntilToday[index].completed.toggle()
            }
            return
        }

        if let index = todoListWithAnyTag.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListWithAnyTag[index].completed.toggle()
            }
            return
        }

        if let index = todoListWithoutTag.firstIndex(where: { $0.id == todoId }) {
            withAnimation {
                todoListWithoutTag[index].completed.toggle()
            }
            return
        }
    }

    func toggleVisibility(
        tagId: String,
        isSeleted: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        tagService.updateIsSelected(
            tagId: tagId,
            isSelected: isSeleted
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

    //  MARK: - Delete

    func deleteTodo(
        todoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        todoService.deleteTodo(todoId: todoId) { result in
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
        todoService.deleteTodoWithRepeat(
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
        todoService.deleteSubTodo(todoId: todoId, subTodoId: subTodoId) { result in
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
