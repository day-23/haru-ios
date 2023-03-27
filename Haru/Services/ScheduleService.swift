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
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/schedules/date",
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

    func fetchScheduleListAsync(
        _ startDate: Date,
        _ endDate: Date
    ) async throws -> [Schedule] {
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

        return try await withCheckedThrowingContinuation { continuation in

            AF.request(
                ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/schedules/date",
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
     * 일정 추가하기
     */
    func addSchedule(_ schedule: Request.Schedule, _ completion: @escaping (Result<Schedule, Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
            let data: Schedule
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
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: encoder),
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

    
}
