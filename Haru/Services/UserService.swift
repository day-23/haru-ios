//
//  UserService.swift
//  Haru
//
//  Created by 이민재 on 2023/05/19.
//

import Alamofire
import Foundation

struct UserService {
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

    // MARK: - CREATE API

    func createTag(
        content: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let params: Parameters = [
            "content": content
        ]

        AF.request(
            UserService.baseURL + "\(Global.shared.user?.id ?? "unknown")/tag",
            method: .post,
            parameters: params,
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

    // MARK: - READ API

    func fetchTags(
        completion: @escaping (Result<[Tag], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Tag]
        }

        AF.request(
            UserService.baseURL + "\(Global.shared.user?.id ?? "unknown")/tags",
            method: .get
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - UPDATE API

    func updateIsSelected(
        tagId: String,
        isSelected: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Tag
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let params: Parameters = [
            "isSelected": !isSelected
        ]

        AF.request(
            UserService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/\(tagId)",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - DELETE API

    func deleteTag(
        tagId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let params: Parameters = [
            "tagIds": [tagId]
        ]

        AF.request(
            UserService.baseURL +
                "\(Global.shared.user?.id ?? "unknown")/tags",
            method: .delete,
            parameters: params,
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
