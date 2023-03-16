//
//  ScheduleFormService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/16.
//

import Alamofire
import Foundation

final class ScheduleFormService {
    private static let baseURL = Constants.baseURL + "schedule/"

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
            ScheduleFormService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .post,
            parameters: schedule,
            encoder: JSONParameterEncoder(encoder: encoder),
            headers: headers
        )
        .responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
