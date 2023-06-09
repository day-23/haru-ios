//
//  UserService.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import Alamofire
import Foundation

struct UserService {
    // MARK: - Properties

    private static let baseURL = Constants.baseURL + "user/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Self.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    func updateUserOption(
        isPublicAccount: Bool? = nil,
        isPostBrowsingEnabled: Bool? = nil,
        isAllowFeedLike: Int? = nil,
        isAllowFeedComment: Int? = nil,
        isAllowSearch: Bool? = nil,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        var params: Parameters = [:]
        if let isPublicAccount {
            params["isPublicAccount"] = isPublicAccount
        }
        if let isPostBrowsingEnabled {
            params["isPostBrowsingEnabled"] = isPostBrowsingEnabled
        }
        if let isAllowFeedLike {
            params["isAllowFeedLike"] = isAllowFeedLike
        }
        if let isAllowFeedComment {
            params["isAllowFeedComment"] = isAllowFeedComment
        }
        if let isAllowSearch {
            params["isAllowSearch"] = isAllowSearch
        }

        AF.request(
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/setting",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data.success))
            case .failure(let error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func updateMorningAlarmTime(
        time: Date?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        struct RequestTime: Codable {
            let morningAlarmTime: Date?

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.morningAlarmTime, forKey: .morningAlarmTime)
            }
        }

        AF.request(
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/setting",
            method: .patch,
            parameters: RequestTime(morningAlarmTime: time),
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data.success))
            case .failure(let error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func updateNightAlarmTime(
        time: Date?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        struct RequestTime: Codable {
            let nightAlarmTime: Date?

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.nightAlarmTime, forKey: .nightAlarmTime)
            }
        }

        AF.request(
            Self.baseURL + "\(Global.shared.user?.id ?? "unknown")/setting",
            method: .patch,
            parameters: RequestTime(nightAlarmTime: time),
            encoder: JSONParameterEncoder(encoder: Self.encoder),
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data.success))
            case .failure(let error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func deleteUser(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        if Global.shared.user?.socialAccountType == "K" {
            // 카카오 계정
            AF.request(
                Self.baseURL + "\(Global.shared.user?.id ?? "unknown")",
                method: .delete,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
                switch response.result {
                case .success(let data):
                    Global.shared.isLoggedIn = false
                    KeychainService.logout()
                    AlarmHelper.removeAllNotification()
                    completion(.success(data.success))
                case .failure(let error):
                    print("[Debug] \(error) \(#fileID) \(#function)")
                }
            }
        } else if Global.shared.user?.socialAccountType == "A" {
            // 애플 계정
        }
    }
}
