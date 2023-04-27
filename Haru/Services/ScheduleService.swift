//
//  ScheduleService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//  Updated by 최정민 on 2023/03/31.
//

import Alamofire
import Foundation

final class ScheduleService {
    private static let baseURL = Constants.baseURL + "schedule/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(ScheduleService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

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

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "startDate": Self.formatter.string(from: startDate),
            "endDate": Self.formatter.string(from: endDate),
        ]

        AF.request(
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/schedules/date",
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

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "startDate": Self.formatter.string(from: startDate),
            "endDate": Self.formatter.string(from: endDate),
        ]

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/schedules/date",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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

        AF.request(
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers
        )
        .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     * 일정 업데이트 API
     */
    func updateSchedule(
        _ scheduleId: String,
        _ schedule: Request.Schedule,
        _ completion: @escaping (Result<Schedule, Error>) -> Void
    ) {
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
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(scheduleId)",
            method: .patch,
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

    /**
     *  달력에 표시될 일정 만드는 함수
     */
    func updateSchedule(scheduleId: String?, schedule: Request.Schedule, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")",
            method: .patch,
            parameters: schedule,
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

    /**
     * 일정 삭제하기 (모든 일정 삭제, 일반 삭제)
     */
    func deleteSchedule(scheduleId: String?, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")",
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

    /**
     * 일정 삭제하기 (이 일정만 삭제)
     */
    func deleteRepeatFrontSchedule(scheduleId: String?, repeatStart: Date, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "repeatStart": Self.formatter.string(from: repeatStart),
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")/repeat/front",
            method: .delete,
            parameters: parameters,
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

    func deleteRepeatMiddleSchedule(scheduleId: String?, removedDate: Date, repeatStart: Date, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "removedDate": Self.formatter.string(from: removedDate),
            "repeatStart": Self.formatter.string(from: repeatStart),
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")/repeat/middle",
            method: .delete,
            parameters: parameters,
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

    func deleteRepeatBackSchedule(scheduleId: String?, repeatEnd: Date, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "repeatEnd": Self.formatter.string(from: repeatEnd),
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")/repeat/back",
            method: .delete,
            parameters: parameters,
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
}
