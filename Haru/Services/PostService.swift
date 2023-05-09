//
//  PostService.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import Alamofire
import Foundation

final class PostService {
    private static let baseURL = Constants.baseURL + "post/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(PostService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    func fetchAllPosts(
        page: Int,
        _ completion: @escaping (Result<([Post], Post.Pagination), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Post]
            let pagination: Post.Pagination
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "page": page,
        ]

        AF.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/posts/all",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success((response.data, response.pagination)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func fetchTargetPosts(
        targetId: String,
        page: Int,
        completion: @escaping (Result<([Post], Post.Pagination), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Post]
            let pagination: Post.Pagination
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "page": page
        ]

        AF.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/posts/user/\(targetId)/feed",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success((response.data, response.pagination)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
