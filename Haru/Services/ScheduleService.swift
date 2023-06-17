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
            let success: Bool
            let data: Data
            let pagination: Pagination

            struct Data: Codable {
                let schedules: [Schedule]
                let holidays: [Holiday]
            }

            struct Pagination: Codable {
                let totalItems: Int
                let startDate: Date
                let endDate: Date
            }
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
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data.schedules))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func fetchScheduleAndTodo(
        _ startDate: Date,
        _ endDate: Date,
        _ completion: @escaping (Result<([Schedule], [Todo]), Error>) -> Void
    ) {
        struct Response: Codable {
            struct Data: Codable {
                let schedules: [Schedule]
                let todos: [Todo]
                let holidays: [Holiday]
            }

            struct Pagination: Codable {
                let totalItems: Int
                let startDate: Date
                let endDate: Date
            }

            let success: Bool
            let data: Data
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
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/schedules/date/all",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
            interceptor: ApiRequestInterceptor()
        )
        .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(
                    .success(
                        (
                            response.data.schedules + response.data.holidays.map { holiday in
                                Schedule.holidayToSchedule(holiday: holiday)
                            },
                            response.data.todos
                        )
                    )
                )
            case let .failure(error):
                completion(.failure(error))
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
            headers: headers,
            interceptor: ApiRequestInterceptor()
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
        scheduleId: String?,
        schedule: Request.Schedule,
        completion: @escaping (Result<Schedule, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Schedule
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            ScheduleService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(scheduleId ?? "unknown")",
            method: .patch,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers,
            interceptor: ApiRequestInterceptor()
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
     * 일정 수정하기 (이 일정만 수정)
     */
    func updateRepeatFrontSchedule(scheduleId: String?, schedule: Request.RepeatSchedule, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")/repeat/front",
            method: .put,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateRepeatMiddleSchedule(scheduleId: String?, schedule: Request.RepeatSchedule, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")/repeat/middle",
            method: .put,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateRepeatBackSchedule(scheduleId: String?, schedule: Request.RepeatSchedule, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId ?? "unknown")/repeat/back",
            method: .put,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateScheduleWithRepeat(
        scheduleId: String,
        schedule: Request.RepeatSchedule,
        at: RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            ScheduleService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/\(scheduleId)/repeat/\(at.rawValue)",
            method: .put,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers,
            interceptor: ApiRequestInterceptor()
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
    func deleteSchedule(scheduleId: String, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId)",
            method: .delete,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                Task {
                    await AlarmHelper.removeNotification(identifier: scheduleId)
                }
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     * 일정 삭제하기 (이 일정만 삭제)
     */
    func deleteRepeatFrontSchedule(scheduleId: String, repeatStart: Date, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "repeatStart": Self.formatter.string(from: repeatStart),
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId)/repeat/front",
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                Task {
                    await AlarmHelper.removeNotification(identifier: scheduleId)
                }
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteRepeatMiddleSchedule(scheduleId: String, removedDate: Date, repeatStart: Date, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "removedDate": Self.formatter.string(from: removedDate),
            "repeatStart": Self.formatter.string(from: repeatStart),
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId)/repeat/middle",
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                Task {
                    await AlarmHelper.removeNotification(identifier: scheduleId)
                }
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func deleteRepeatBackSchedule(scheduleId: String, repeatEnd: Date, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "repeatEnd": Self.formatter.string(from: repeatEnd),
        ]

        AF.request(
            ScheduleService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(scheduleId)/repeat/back",
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
            interceptor: ApiRequestInterceptor()
        ).response { response in
            switch response.result {
            case .success:
                Task {
                    await AlarmHelper.removeNotification(identifier: scheduleId)
                }
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
