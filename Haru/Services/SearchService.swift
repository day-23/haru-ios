//
//  SearchService.swift
//  Haru
//
//  Created by 이준호 on 2023/06/03.
//

import Alamofire
import Foundation

final class SearchService {
    // MARK: - Properties

    private static let prodBaseURL = Constants.baseURL + "schedule/"
    private static let userBaseURL = Constants.baseURL + "post/"
    private static let friendBaseURL = Constants.baseURL + "friends/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(SearchService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    // MARK: - 일정과 할일 검색

    func searchTodoAndSchedule(
        searchContent: String,
        completion: @escaping (Result<([Schedule], [Todo]), Error>) -> Void
    ) {
        struct Response: Codable {
            struct Data: Codable {
                let schedules: [Schedule]
                let todos: [Todo]
            }

            let success: Bool
            let data: Data
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "content": searchContent,
        ]

        AF.request(
            SearchService.prodBaseURL + (Global.shared.user?.id ?? "unknown") + "/search",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
        .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success((response.data.schedules, response.data.todos)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 사용자 검색

    func searchUserWithHaruId(
        haruId: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: User
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            SearchService.userBaseURL + (Global.shared.user?.id ?? "unknown") + "/search/user/\(haruId)",
            method: .get,
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

    func searchFriendWithName(
        name: String,
        completion: @escaping (Result<[FriendUser], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [FriendUser]
            let pagination: Post.Pagination
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "name": name,
        ]

        AF.request(
            SearchService.friendBaseURL + (Global.shared.user?.id ?? "unknown") + "/search/",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
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

    func searchReqFriendWithName(
        name: String,
        completion: @escaping (Result<[FriendUser], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [FriendUser]
            let pagination: Post.Pagination
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "name": name,
        ]

        AF.request(
            SearchService.friendBaseURL + (Global.shared.user?.id ?? "unknown") + "/request/search/",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
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
}
