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
        do {
            async let scheduleList = scheduleService.fetchScheduleListAsync(startDate, endDate)
            async let todoList = fetchTodoListAsync(startDate, endDate)

            return try await (scheduleList, todoList)
        } catch {
            print("[Debug] \(error) \(#fileID) \(#function)")
        }
        return ([], [])
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
        var result = [[Int: [Productivity]]](repeating: [:], count: dateList.count) // 날짜별

        var result_ = [[[(Int, Productivity?)]]](repeating: [[(Int, Productivity?)]](repeating: [], count: prodCnt), count: numberOfWeeks) // 순서

        scheduleService.fittingScheduleList(dateList, scheduleList, prodCnt, result: &result, result_: &result_)

        // TODO: todoService의 fittingTodoList 함수로 뽑기
        let todoList = todoList.filter { $0.endDate != nil }
        var p = 0
        for index in dateList.indices {
            var maxKey = result[index].max { $0.key < $1.key }?.key ?? -1
            maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
            while p < todoList.count, dateList[index].date.isEqual(other: todoList[p].endDate!) {
                result[index][maxKey] = (result[index][maxKey] ?? []) + [todoList[p]]
                p += 1
                maxKey = maxKey > prodCnt ? maxKey : maxKey + 1
            }
        }

        // MARK: -

        for week in 0 ..< numberOfWeeks {
            for order in 0 ..< prodCnt {
                var prev = result[week * 7 + 0][order]?.first
                var cnt = 1
                for day in 1 ..< 7 {
                    if let prev, let prod = result[week * 7 + day][order]?.first, prev.isEqualTo(prod) {
                        cnt += 1
                    } else {
                        result_[week][order].append((cnt, prev))
                        cnt = 1
                    }
                    prev = result[week * 7 + day][order]?.first
                }
                result_[week][order].append((cnt, prev))
            }
        }

        return (result, result_)
    }
}
