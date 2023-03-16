//
//  TodoService.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Alamofire
import Foundation

struct TodoService {
    private static let baseURL = Constants.baseURL + "todo/"

    // Todo 생성 API 호출
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

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy

        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        AF.request(
            TodoService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: encoder),
            headers: headers
        ).responseDecodable(
            of: Response.self,
            decoder: decoder
        ) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // 나의 Todo 목록 가져오기
    func fetchTodoList(completion: @escaping (Result<[Todo], Error>) -> Void) {
        struct Response: Codable {
            struct Pagination: Codable {
                let totalItems: Int
                let itemsPerPage: Int
                let currentPage: Int
                let totalPages: Int
            }

            let success: Bool
            let data: [Todo]
            let pagination: Pagination
        }

        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        AF.request(
            TodoService.baseURL + "\(Global.shared.user?.id ?? "unknown")/todos"
        ).responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
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

        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        AF.request(
            TodoService
                .baseURL +
                "\(Global.shared.user?.id ?? "unknown")/todos/tag?tagId=\(tag.id)"
        ).responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // Todo Update
    func updateTodo(
        _ todoId: String,
        _ todo: Request.Todo,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy

        print(todo, "\n")
        print(String(data: try! encoder.encode(todo), encoding: .utf8))

        AF.request(
            TodoService
                .baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
            method: .patch,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: encoder),
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

    // Todo 중요 표시하기
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
            TodoService
                .baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
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

    // Todo 삭제하기
    func deleteTodo(
        _ todoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        AF.request(
            TodoService
                .baseURL + "\(Global.shared.user?.id ?? "unknown")/\(todoId)",
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

    // SubTodo 삭제하기
    func deleteSubTodo(
        _ todoId: String,
        _ subTodoId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        AF.request(
            TodoService
                .baseURL +
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
