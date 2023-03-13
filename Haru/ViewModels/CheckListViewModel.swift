//
//  CheckListViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

final class CheckListViewModel: ObservableObject {
    // MARK: - Properties

    private let todoService: TodoService = .init()
    private let tagService: TagService = .init()
    @Published var todoList: [Todo] = []
    @Published var tagList: [Tag] = []

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
                    Todo(id: self.todoList.count.description,
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

    func fetchTodoList(completion: @escaping (_ statusCode: Int, [Todo]) -> Void) {
        todoService.fetchTodoList { statusCode, todoList in
            switch statusCode {
            case 200:
                self.todoList = todoList
            case -1:
                print("[Debug] Server not running now.")
            default:
                print("[Debug] StatusCode = \(statusCode) in CheckListViewModel.fetchTodoList()")
            }
        }
    }

    func updateFlag(_ todo: Todo, completion: @escaping () -> Void) {
        guard let index = todoList.firstIndex(where: { $0.id == todo.id }) else {
            print("[Debug] Todo를 찾지 못했습니다.")
            return
        }

        todoService.updateFlag(todo.id, !todo.flag) { statusCode in
            switch statusCode {
            case 200:
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
                completion()
            case -1:
                print("[Debug] Server not running now.")
            default:
                print("[Debug] StatusCode = \(statusCode) in CheckListViewModel.deleteTodo(_ todoId: String)")
            }
        }
    }

    func deleteTodo(_ todoId: String, completion: @escaping () -> Void) {
        todoService.deleteTodo(todoId) { statusCode in
            switch statusCode {
            case 200:
                completion()
            case -1:
                print("[Debug] Server not running now.")
            default:
                print("[Debug] StatusCode = \(statusCode) in CheckListViewModel.deleteTodo(_ todoId: String)")
            }
        }
    }
}
