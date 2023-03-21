//
//  TodoService.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Alamofire
import Foundation

struct TodoService {
    // MARK: - Properties

    private static let baseURL = Constants.baseURL + "todo/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(TodoService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    // MARK: - Todo Create API

    func addTodo(
        todo: Request.Todo,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Todo
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            TodoService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: TodoService.encoder),
            headers: headers
        ).responseDecodable(
            of: Response.self,
            decoder: TodoService.decoder
        ) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Todo Read API

    func fetchTodoList(
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
            let pagination: Pagination

            struct Pagination: Codable {
                let totalItems: Int
                let itemsPerPage: Int
                let currentPage: Int
                let totalPages: Int
            }
        }

        AF.request(
            TodoService.baseURL + "\(Global.shared.user?.id ?? "unknown")/todos"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func fetchMainTodoList(
        completion: @escaping (Result<(flaggedTodos: [Todo],
                                       taggedTodos: [Todo],
                                       untaggedTodos: [Todo],
                                       completedTodos: [Todo]), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
                let flaggedTodos: [Todo]
                let taggedTodos: [Todo]
                let untaggedTodos: [Todo]
                let completedTodos: [Todo]
            }
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                let data = response.data
                completion(.success((
                    flaggedTodos: data.flaggedTodos,
                    taggedTodos: data.taggedTodos,
                    untaggedTodos: data.untaggedTodos,
                    completedTodos: data.completedTodos
                )))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListByTodayTodoAndUntilToday(
        today: Date,
        completion: @escaping (Result<(flaggedTodos: [Todo], todayTodos: [Todo], endDateTodos: [Todo]), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
                let flaggedTodos: [Todo]
                let todayTodos: [Todo]
                let endDatedTodos: [Todo]
            }
        }

        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/today?endDate=\(formatter.string(from: today))"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                let data = response.data
                completion(.success((
                    flaggedTodos: data.flaggedTodos,
                    todayTodos: data.todayTodos,
                    endDateTodos: data.endDatedTodos
                )))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListByFlag(
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/flag"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListWithAnyTag(
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/tag"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListWithoutTag(
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/untag"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListByCompletedInMain(
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/completed"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListByTag(
        tag: Tag,
        completion: @escaping (Result<(todos: [Todo], completedTodos: [Todo]), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
                let todos: [Todo]
                let completedTodos: [Todo]
            }
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/tag?tagId=\(tag.id)"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                let data = response.data
                completion(.success((todos: data.todos, completedTodos: data.completedTodos)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Todo Update API

    func updateTodo(
        todoId: String,
        todo: Request.Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            TodoService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
            method: .patch,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: TodoService.encoder),
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateFlag(
        todoId: String,
        flag: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "flag": flag,
        ]

        AF.request(
            TodoService.baseURL + "\(Global.shared.user?.id ?? "unknown")/flag/\(todoId)",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateOrderMain(
        todoListByFlag: [Todo],
        todoListWithAnyTag: [Todo],
        todoListWithoutTag: [Todo],
        todoListByCompleted: [Todo]
    ) {
        var todoIds: [String] = []
        todoIds = todoListByFlag.map { $0.id } + todoListWithAnyTag.map { $0.id } +
            todoListWithoutTag.map { $0.id } + todoListByCompleted.map { $0.id }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "todoIds": todoIds,
        ]

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/order/todos/",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                break
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
            }
        }
    }

    func updateOrderHaru(
        todoListByFlagWithToday: [Todo],
        todoListByTodayTodo: [Todo],
        todoListByUntilToday: [Todo]
    ) {
        var todoIds: [String] = []
        todoIds = todoListByFlagWithToday.map { $0.id } +
            todoListByTodayTodo.map { $0.id } +
            todoListByUntilToday.map { $0.id }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "todoIds": todoIds,
        ]

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/order/todos/today",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                break
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
            }
        }
    }

    func updateOrderFlag(
        todoListByFlag: [Todo]
    ) {
        let todoIds: [String] = todoListByFlag.map { $0.id }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "todoIds": todoIds,
        ]

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/order/todos",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                break
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
            }
        }
    }

    func updateOrderWithoutTag(
        todoListWithoutTag: [Todo]
    ) {
        let todoIds: [String] = todoListWithoutTag.map { $0.id }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "todoIds": todoIds,
        ]

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/order/todos",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                break
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
            }
        }
    }

    func updateOrderByTag(
        tagId: String,
        todoListByTag: [Todo]
    ) {
        let todoIds: [String] = todoListByTag.map { $0.id }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "tagId": tagId,
            "todoIds": todoIds,
        ]

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/order/todos/tag",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                break
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
            }
        }
    }

    // MARK: - Todo Delete API

    func deleteTodo(
        todoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        AF.request(
            TodoService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
            method: .delete
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteTag(
        todoId: String,
        tagId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/\(todoId)/tag/\(tagId)",
            method: .delete
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
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
        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/\(todoId)/subtodo/\(subTodoId)",
            method: .delete
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
