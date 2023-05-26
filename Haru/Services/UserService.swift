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
}
