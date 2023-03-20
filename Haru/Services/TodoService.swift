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
        _ todo: Request.Todo,
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

    func fetchTodoList(completion: @escaping (Result<[Todo], Error>) -> Void) {
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

    func fetchTodayTodoList(
        _ today: Date,
        completion: @escaping (Result<(todayTodos: [Todo], endDateTodos: [Todo]), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
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
                completion(.success((todayTodos: data.todayTodos, endDateTodos: data.endDatedTodos)))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func fetchTodoListWithFlagInMain(
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

    func fetchTodoListWithTagInMain(
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

    func fetchTodoListWithoutTagInMain(
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

    func fetchTodoListWithCompletedInMain(
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

    func fetchTodoListWithTag(
        _ tag: Tag,
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
        }

        AF.request(
            TodoService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/tag?tagId=\(tag.id)"
        ).responseDecodable(of: Response.self, decoder: TodoService.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Todo Update API

    func updateTodo(
        _ todoId: String,
        _ todo: Request.Todo,
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
        _ todoId: String,
        _ flag: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "flag": flag,
        ]

        AF.request(
            TodoService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
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

    // MARK: - Todo Delete API

    func deleteTodo(
        _ todoId: String,
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
        _ todoId: String,
        _ tagId: String,
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
        _ todoId: String,
        _ subTodoId: String,
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
