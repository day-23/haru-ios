//
//  CommentService.swift
//  Haru
//
//  Created by 이준호 on 2023/05/13.
//

import Alamofire
import Foundation

final class CommentService {
    private static let baseURL = Constants.baseURL + "comment/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let iSO8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(CommentService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    func createComment(
        targetPostId: String,
        targetPostImageId: String,
        comment: Request.Comment,
        completion: @escaping (Result<Post.Comment, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Post.Comment
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            CommentService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(targetPostId)/\(targetPostImageId)",
            method: .post,
            parameters: comment,
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

//    func updateComment(
//        targetPostId: String,
//        targetPostImageId: String,
//        comment: Request.Comment,
//        completion: @escaping(Result<Post.)
//    )

    func deleteComment(
        targetCommentId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            CommentService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(targetCommentId)",
            method: .delete,
            headers: headers
        ).responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.success))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
