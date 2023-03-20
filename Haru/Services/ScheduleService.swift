//
//  ScheduleService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Alamofire
import Foundation

final class ScheduleService {
    private static let baseURL = Constants.baseURL + "schedule/"
    /**
     * 현재 선택된 달을 기준으로 이전 달, (선택된) 현재 달, 다음 달의 스케줄 데이터 가져오기
     */
    func fetchScheduleList(
        _ startDate: Date,
        _ endDate: Date,
        _ completion: @escaping (Result<[Schedule], Error>) -> Void
    ) {
        struct Response: Codable {
            struct Pagination: Codable {
                let totalItems: Int
                let startDate: Date
                let endDate: Date
            }

            let success: Bool
            let data: [Schedule]
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

        AF.request(
            ScheduleService.baseURL + Global.shared.user!.id + "/schedules/date",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.queryString,
            headers: headers
        )
        .responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func fittingScheduleList(
        _ dateList: [DateValue],
        _ scheduleList: [Schedule]
    ) -> [[Int: [Schedule]]] {
        let numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)

        // 주차별 스케줄
        var weeksOfScheduleList = [[Schedule]](repeating: [], count: numberOfWeeks)

        var result = [[Int: [Schedule]]](repeating: [:], count: dateList.count)

//        var _result = [[(Int, Schedule)]](repeating: [(Int, Schedule)](repeating: (Int, Schedule).Type, count: 7), count: 4)

        var splitDateList = [[Date]]() // row: 주차, col: row주차에 있는 날짜들

        for row in 0 ..< numberOfWeeks {
            splitDateList.append([dateList[row * 7 + 0].date, dateList[row * 7 + 6].date])
        }

        for schedule in scheduleList {
            for (week, dates) in splitDateList.enumerated() {
                if schedule.repeatEnd < dates[0] {
                    break
                }
                if schedule.repeatStart >= dates[1] {
                    continue
                }
                weeksOfScheduleList[week].append(schedule)
            }
        }

        for (week, weekOfSchedules) in weeksOfScheduleList.enumerated() {
            // 주 단위
            var orders = Array(repeating: Array(repeating: true, count: 5), count: 7)
            for schedule in weekOfSchedules {
                var order = 0
                var isFirst = true

                for (index, dateValue) in dateList[week * 7 ..< (week + 1) * 7].enumerated() {
                    if schedule.repeatStart < Calendar.current.date(
                        byAdding: .day,
                        value: 1,
                        to: dateValue.date
                    )!,
                        schedule.repeatEnd >= dateValue.date
                    {
                        if isFirst {
                            var i = 0
                            while i < 4, !orders[index][i] {
                                i += 1
                            }
                            order = i
                            orders[index][i] = false
                            isFirst = false
                        }
                        orders[index][order] = false
                        result[week * 7 + index][order] = (result[week * 7 + index][order] ?? []) + [schedule]
                    }
                }
            }
        }

        return result
    }
}
