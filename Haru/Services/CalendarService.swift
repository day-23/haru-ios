//
//  CalendarService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/22.
//

import Alamofire
import Foundation

final class CalendarService {
    // TODO: calendarservice -> CalendarViewModel로 함수 이전시키기
    private var scheduleService: ScheduleService = .init()

    /**
     * 일정과 할일 가져오기
     */
//    func fetchScheduleAndTodo(_ startDate: Date, _ endDate: Date) async -> ([Schedule], [Todo]) {
//        print("call schedule & todo API")
//        do {
    ////            async let scheduleList = scheduleService.fetchScheduleListAsync(startDate, endDate)
//
//            // FIXME: struct Todo 변경되면 수정해주기
//            async let todoList = fetchTodoListAsync(startDate, endDate)
//
//            return try await (scheduleList, todoList)
//        } catch {
//            print("[Debug] \(error) \(#fileID) \(#function)")
//            return ([], [])
//        }
//    }

    /**
     * 할일 가져오기 (나중에 TodoService로 옮기기)
     */
    func fetchTodoListAsync(_ startDate: Date, _ endDate: Date) async throws -> [Todo] {
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

            AF.request(
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
