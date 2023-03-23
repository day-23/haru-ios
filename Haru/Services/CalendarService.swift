//
//  CalendarService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/22.
//

import Alamofire
import Foundation

final class CalendarService {
    private var scheduleService: ScheduleService = .init()

    /**
     * 일정과 할일 가져오기
     */
    func fetchScheduleAndTodo(_ startDate: Date, _ endDate: Date) async -> ([Schedule], [Todo]) {
        var scheduleList: [Schedule] = []
        var todoList: [Todo] = []

        do {
            scheduleList = try await scheduleService.fetchScheduleListAsync(startDate, endDate)
            todoList = try await fetchTodoListAsync(startDate, endDate)
        } catch {
            print("[Debug] \(error)")
        }

        return (scheduleList, todoList)
    }

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

        let paramFormatter = DateFormatter()
        paramFormatter.dateFormat = "yyyyMMdd"

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "startDate": paramFormatter.string(from: startDate),
            "endDate": paramFormatter.string(from: endDate),
        ]

        return try await withCheckedThrowingContinuation { continuation in

            AF.request(
                Constants.baseURL + "todo/" + (Global.shared.user?.id ?? "unknown") + "/todos/date",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.queryString,
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

    /**
     * 달력에 보여질 일정과 할일 만드는 함수
     */
    func fittingCalendar(
        dateList: [DateValue],
        scheduleList: [Schedule],
        todoList: [Todo]
    ) -> ([[Int: [Productivity]]], [[[(Int, Productivity?)]]]) {
        // 주차 개수
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 최대 보여줄 수 있는 일정, 할일 개수
        let prodCnt = numberOfWeeks < 6 ? 4 : 3

        // 최종 결과
        var result = [[Int: [Productivity]]](repeating: [:], count: dateList.count)

        var result_ = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: prodCnt), count: numberOfWeeks)

        scheduleService.fittingScheduleList(dateList, scheduleList, prodCnt, result: &result, result_: &result_)

        return (result, result_)
    }
}
