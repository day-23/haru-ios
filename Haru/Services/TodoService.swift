//
//  TodoService.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Alamofire
import Foundation

struct TodoService {
    //  MARK: - Properties

    enum RepeatAt: String {
        case front
        case middle
        case back
    }

    private static let baseURL = Constants.baseURL + "todo/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Self.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    //  MARK: - Todo Create API

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
            Self.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers
        ).responseDecodable(
            of: Response.self,
            decoder: Self.decoder
        ) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    //  MARK: - Todo Read API

    func fetchAllTodoList(
        completion: @escaping (Result<(
            flaggedTodos: [Todo],
            taggedTodos: [Todo],
            untaggedTodos: [Todo],
            completedTodos: [Todo],
            todayTodos: [Todo],
            todayFlaggedTodos: [Todo],
            endDatedTodos: [Todo]
        ), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
                let flaggedTodos: [Todo]
                let taggedTodos: [Todo]
                let untaggedTodos: [Todo]
                let completedTodos: [Todo]
                let todayTodos: [Todo]
                let todayFlaggedTodos: [Todo]
                let endDatedTodos: [Todo]
            }
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "endDate": "\(Date.now.year)-\(Date.now.month < 10 ? "0" : "")\(Date.now.month)-\(Date.now.day < 10 ? "0" : "")\(Date.now.day)T00:00:00+09:00",
        ]

        AF.request(
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/todos/all",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(
                    .success((
                        flaggedTodos: response.data.flaggedTodos,
                        taggedTodos: response.data.taggedTodos,
                        untaggedTodos: response.data.untaggedTodos,
                        completedTodos: response.data.completedTodos,
                        todayTodos: response.data.todayTodos,
                        todayFlaggedTodos: response.data.todayFlaggedTodos,
                        endDatedTodos: response.data.endDatedTodos
                    ))
                )
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

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
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/todos"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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
        completion: @escaping (
            Result<(
                flaggedTodos: [Todo],
                todayTodos: [Todo],
                endDateTodos: [Todo],
                completedTodos: [Todo]
            ), Error>
        ) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
                let flaggedTodos: [Todo]
                let todayTodos: [Todo]
                let endDatedTodos: [Todo]
                let completedTodos: [Todo]
            }
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "endDate": "\(Date.now.year)-\(Date.now.month < 10 ? "0" : "")\(Date.now.month)-\(Date.now.day < 10 ? "0" : "")\(Date.now.day)T00:00:00+09:00",
        ]

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/today",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                let data = response.data
                completion(.success((
                    flaggedTodos: data.flaggedTodos,
                    todayTodos: data.todayTodos,
                    endDateTodos: data.endDatedTodos,
                    completedTodos: data.completedTodos
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
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/flag"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/tag"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/untag"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/main/completed"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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
        completion: @escaping (Result<(
            flaggedTodos: [Todo],
            unFlaggedTodos: [Todo],
            completedTodos: [Todo]
        ), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Data

            struct Data: Codable {
                let flaggedTodos: [Todo]
                let unFlaggedTodos: [Todo]
                let completedTodos: [Todo]
            }
        }

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/tag?tagId=\(tag.id)"
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                let data = response.data
                completion(.success((
                    flaggedTodos: data.flaggedTodos,
                    unFlaggedTodos: data.unFlaggedTodos,
                    completedTodos: data.completedTodos
                )))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func fetchTodoListByRange(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Todo]
            let pagination: Pagination

            struct Pagination: Codable {
                let totalItems: Int
                let startDate: Date
                let endDate: Date
            }
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "startDate": Self.formatter.string(from: startDate),
            "endDate": Self.formatter.string(from: endDate),
        ]

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/date",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    //  MARK: - Todo Update API

    func updateTodo(
        todoId: String,
        todo: Request.Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
            method: .put,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
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

    func updateTodoWithRepeat(
        todoId: String,
        todo: Request.Todo,
        date: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        var params: Parameters = todo.dictionary
        if at == .front || at == .middle {
            params["nextEndDate"] = Self.formatter.string(from: date)
            if at == .middle {
                params["changedDate"] = Self.formatter.string(from: .now)
            }
        }
        if at == .back {
            params["preRepeatEnd"] = Self.formatter.string(from: date)
        }

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todo/\(todoId)/repeat/\(at.rawValue)",
            method: .put,
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
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/flag/\(todoId)",
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

    func updateFolded(
        todoId: String,
        folded: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "folded": folded,
        ]

        AF.request(
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/folded/\(todoId)",
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
            Self.baseURL +
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
            Self.baseURL +
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
            Self.baseURL +
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
            Self.baseURL +
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
            Self.baseURL +
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

    func completeTodo(
        todoId: String,
        completed: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "completed": completed,
        ]

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/complete/todo/\(todoId)",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
                completion(.failure(error))
            }
        }
    }

    func completeSubTodo(
        subTodoId: String,
        completed: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: [String: Any] = [
            "completed": completed,
        ]

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/complete/subtodo/\(subTodoId)",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
                completion(.failure(error))
            }
        }
    }

    func completeTodoWithRepeat(
        todoId: String,
        nextEndDate endDate: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        var params: [String: Any] = [
            "endDate": Self.formatter.string(from: endDate),
        ]

        if at == .middle {
            params["completedDate"] = Self.formatter.string(from: .now)
        }

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/complete/todo/\(todoId)/repeat/\(at.rawValue)",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
                completion(.failure(error))
            }
        }
    }

    //  MARK: - Todo Delete API

    func deleteTodo(
        todoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        AF.request(
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
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

    func deleteTodoWithRepeat(
        todoId: String,
        date: Date,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        var params: Parameters = [:]

        if at == .front || at == .middle {
            params["endDate"] = Self.formatter.string(from: date)
            if at == .middle {
                params["removedDate"] = Self.formatter.string(from: .now)
            }
        }

        if at == .back {
            params["repeatEnd"] = Self.formatter.string(from: date)
        }

        AF.request(
            Self.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todo/\(todoId)/repeat/\(at.rawValue)",
            method: .delete,
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

    func deleteTag(
        todoId: String,
        tagId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        AF.request(
            Self.baseURL +
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
            Self.baseURL +
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
