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
    func addTodo(_ userId: String, _ todo: Request.Todo, completion: @escaping (_ statusCode: Int) -> Void) {
        let body: [String: Any?] = [
            "content": todo.content,
            "memo": todo.memo,
            "todayTodo": todo.todayTodo,
            "flag": todo.flag,
            "repeatOption": nil,
            "repeat": nil,
            "tags": todo.tags
        ]

        AF.request(
            TodoService.BaseUrl + "\(userId)",
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default
        ).response { response in
            if let statusCode = response.response?.statusCode {
                completion(statusCode)
            }
        }
    }
}
