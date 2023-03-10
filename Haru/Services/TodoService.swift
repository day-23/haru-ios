//
//  TodoService.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Alamofire
import Foundation

struct TodoService {
    private static let BaseUrl = "http://localhost:8000/todo/"

    // Todo 생성 API 호출
    func addTodo(_ todo: Request.Todo, completion: @escaping (_ statusCode: Int) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy

        AF.request(
            TodoService.BaseUrl + (Global.shared.user?.id ?? "Unknown"),
            method: .post,
            parameters: todo,
            encoder: JSONParameterEncoder(encoder: encoder),
            headers: headers
        ).response { response in
            if let statusCode = response.response?.statusCode {
                completion(statusCode)
            }
        }
    }

    // 나의 Todo 목록 가져오기
    func fetchTodoList(completion: @escaping (_ statusCode: Int, [Todo]) -> Void) {
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

        AF.request(
            TodoService.BaseUrl + "\(Global.shared.user?.id ?? "Unknown")/todos"
        ).response { response in
            guard let statusCode = response.response?.statusCode else {
                completion(-1, [])
                return
            }

            if statusCode != 200 {
                completion(statusCode, [])
                return
            }

            guard let data = response.data else { return }

            let decoder: JSONDecoder = {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    let formatter = DateFormatter()
                    formatter.dateFormat = Constants.dateFormat
                    if let date = formatter.date(from: dateString) {
                        return date
                    }

                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                return decoder
            }()

            do {
                let result = try decoder.decode(Response.self, from: data)
                if result.success {
                    completion(statusCode, result.data)
                }
            } catch {
                print("[Debug] \(String(describing: error))")
            }
        }
    }

    // Todo 중요 표시하기
    func updateFlag(_ todoId: String, _ flag: Bool, completion: @escaping (_ statusCode: Int) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let params: [String: Any] = [
            "flag": flag
        ]

        AF.request(
            TodoService.BaseUrl + "\(Global.shared.user?.id ?? "Unknown")/\(todoId)",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            guard let statusCode = response.response?.statusCode else {
                completion(-1)
                return
            }

            completion(statusCode)
        }
    }

    // Todo 삭제하기
    func deleteTodo(_ todoId: String, completion: @escaping (_ statusCode: Int) -> Void) {
        AF.request(
            TodoService.BaseUrl + "\(Global.shared.user?.id ?? "Unknown")/\(todoId)",
            method: .delete
        ).response { response in
            guard let statusCode = response.response?.statusCode else {
                completion(-1)
                return
            }

            completion(statusCode)
        }
    }
}
