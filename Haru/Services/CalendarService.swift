//
//  CalendarService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/22.
//

import Alamofire
import Foundation

final class CalendarService {
    private init() {}

    /**
     * 할일 가져오기 (나중에 TodoService로 옮기기)
     */
    public static func fetchTodoListAsync(_ startDate: Date, _ endDate: Date) async throws -> [Todo] {
        struct Response: Codable {
            struct Pagination: Codable {
                let totalItems: Int
                let startDate: Date
                let endDate: Date
            }

            let success: Bool
            let data: [Todo]
            let pagination: Pagination
        }

        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "startDate": formatter.string(from: startDate),
            "endDate": formatter.string(from: endDate),
        ]

        return try await withCheckedThrowingContinuation { continuation in

            AFProxy.request(
                Constants.baseURL + "todo/" + (Global.shared.user?.id ?? "unknown") + "/todos/date",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .responseDecodable(of: Response.self, decoder: decoder) { response in
                switch response.result {
                case let .success(response):
                    continuation.resume(returning: response.data)

                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
