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
            case .success(let tagList):
                self.tagList = tagList
                completion(.success(tagList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func addTodo(_ todo: Request.Todo, completion: @escaping (Result<Todo, Error>) -> Void) {
        todoService.addTodo(todo) { result in
            switch result {
            case .success(let todo):
                self.todoList.insert(
                    Todo(id: todo.id,
                         content: todo.content,
                         memo: todo.memo,
                         todayTodo: todo.todayTodo,
                         flag: todo.flag,
                         repeatOption: todo.repeatOption,
                         repeat: todo.repeat,
                         alarms: todo.alarms,
                         endDate: todo.endDate,
                         endDateTime: todo.endDateTime,
                         subTodos: todo.subTodos,
                         tags: todo.tags,
                         createdAt: Date()),
                    at: 0
                )
                completion(.success(todo))
            case .failure(let error):
                print("[Debug] \(error) in CheckListViewModel.addTodo(_ todo: Request.Todo)")
                completion(.failure(error))
            }
        }
    }

    func fetchTodoList(completion: @escaping (Result<[Todo], Error>) -> Void) {
        todoService.fetchTodoList { result in
            switch result {
            case .success(let todoList):
                withAnimation {
                    self.todoList = todoList
                }
                completion(.success(todoList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchTodayTodoList(completion: @escaping (Result<[Todo], Error>) -> Void) {
        todoService.fetchTodoList { result in
            switch result {
            case .success(let todoList):
                self.todoList = todoList.filter { $0.todayTodo || $0.endDate?.compare(Date.now) == .orderedSame }
            case .failure(let error):
                print("[Debug] \(error) in CheckListViewModel.fetchTodayTodoList")
            }
        }
    }

    func fetchTodoListWithAnyTag() {
        todoService.fetchTodoList { result in
            switch result {
            case .success(let todoList):
                self.todoList = todoList.filter { !$0.tags.isEmpty }
            case .failure(let error):
                print("[Debug] \(error) in CheckListViewModel.fetchTodoListWithAnyTag")
            }
        }
    }

    func fetchTodoListWithTag(_ tag: Tag, completion: @escaping (Result<[Todo], Error>) -> Void) {
        todoService.fetchTodoListWithTag(tag) { result in
            switch result {
            case .success(let todoList):
                self.todoList = todoList
                completion(.success(todoList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchTodoListWithFlag() {
        todoService.fetchTodoList { result in
            switch result {
            case .success(let todoList):
                self.todoList = todoList.filter { $0.flag }
            case .failure(let error):
                print("[Debug] \(error) in CheckListViewModel.fetchTodoListWithFlag()")
            }
        }
    }

    func fetchTodoListWithoutTag() {
        todoService.fetchTodoList { result in
            switch result {
            case .success(let todoList):
                self.todoList = todoList.filter { $0.tags.isEmpty }
            case .failure(let error):
                print("[Debug] \(error) in CheckListViewModel.fetchTodoListWithOutTag()")
            }
        }
    }

    func fetchTodoListWithCompleted() {
        todoService.fetchTodoList { result in }
    }

    func updateFlag(_ todo: Todo, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let index = todoList.firstIndex(where: { $0.id == todo.id }) else {
            print("[Debug] Todo를 찾지 못했습니다.")
            return
        }

        todoService.updateFlag(todo.id, !todo.flag) { result in
            switch result {
            case .success(let success):
                withAnimation(.easeOut(duration: 0.25)) {
                    self.todoList[index] = Todo(
                        id: todo.id,
                        content: todo.content,
                        memo: todo.memo,
                        todayTodo: todo.todayTodo,
                        flag: !todo.flag,
                        repeatOption: todo.repeatOption,
                        repeat: todo.repeat,
                        alarms: todo.alarms,
                        endDate: todo.endDate,
                        endDateTime: todo.endDateTime,
                        subTodos: todo.subTodos,
                        tags: todo.tags,
                        createdAt: todo.createdAt,
                        updatedAt: todo.updatedAt,
                        deletedAt: todo.deletedAt
                    )
                }
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteTodo(_ todo: Todo, completion: @escaping (Result<Bool, Error>) -> Void) {
        todoService.deleteTodo(todo.id) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteSubTodo(_ todo: Todo, _ subTodo: SubTodo, completion: @escaping (Result<Bool, Error>) -> Void) {
        todoService.deleteSubTodo(todo.id, subTodo.id) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - TodoList 분류하는 함수 (API 이용 fetch가 아닙니다.)

    func filterTodoByFlag() -> [Todo] {
        return todoList.filter { $0.flag }
    }

    func filterTodoByHasAnyTag() -> [Todo] {
        return todoList.filter { !$0.tags.isEmpty }
    }

    func filterTodoByWithoutTag() -> [Todo] {
        return todoList.filter { $0.tags.isEmpty }
    }

    func filterTodoByTodayTodo() -> [Todo] {
        return todoList.filter { $0.todayTodo }
    }

    func filterTodoByTodayEndDate() -> [Todo] {
        return todoList.filter { $0.endDate?.compare(Date.now) == .orderedSame }
    }
}
