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

    // 이미지 게시물에 댓글 작성
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

    // 템플릿 게시물에 댓글 작성
    func createCommentTemplate(
        targetPostId: String,
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
            CommentService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(targetPostId)/",
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

    // 이미지 게시물의 댓글 수정 (ver.1에서는 기능 사용 안함)
    func updateComment(
        targetUserId: String,
        targetCommentId: String,
        comment: Request.Comment,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AF.request(
            CommentService.baseURL + "\(targetUserId)/\(targetCommentId)",
            method: .patch,
            parameters: comment,
            encoder: JSONParameterEncoder.default,
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
    
    func updateCommentList(
        targetPostId: String,
        targetCommentIdList: [String],
        xList: [Double],
        yList: [Double],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let commentIds: [String] = targetCommentIdList
        let x: [Double] = xList
        let y: [Double] = yList

        let parameters: [String: Any] = [
            "commentIds": commentIds,
            "x": x,
            "y": y,
        ]

        AF.request(
            CommentService.baseURL + "\(Global.shared.user?.id ?? "unknown")/\(targetPostId)/comments/",
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                print("[Debug] \(error) \(#fileID) \(#function)")
                completion(.failure(error))
            }
        }
    }

    func deleteComment(
        targetUserId: String,
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
            CommentService.baseURL + "\(targetUserId)/\(targetCommentId)",
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

    // MARK: - 댓글 리스트용 api

    func fetchTargetImageComment(
        userId: String,
        postId: String,
        imageId: String,
        page: Int,
        limit: Int = 20,
        lastCreatedAt: Date? = nil,
        completion: @escaping (Result<([Post.Comment], Post.Pagination), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Post.Comment]
            let pagination: Post.Pagination
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        var parameters: Parameters {
            if let lastCreatedAt {
                return [
                    "page": page,
                    "limit": limit,
                    "lastCreatedAt": Self.iSO8601Formatter.string(from: lastCreatedAt),
                ]
            } else {
                return [
                    "page": page,
                    "limit": limit,
                ]
            }
        }

        AF.request(
            CommentService.baseURL + userId + "/\(postId)/\(imageId)/comments/all",
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
    
    func fetchTargetTemplateComment(
        userId: String,
        postId: String,
        page: Int,
        limit: Int = 20,
        lastCreatedAt: Date? = nil,
        completion: @escaping (Result<([Post.Comment], Post.Pagination), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [Post.Comment]
            let pagination: Post.Pagination
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        var parameters: Parameters {
            if let lastCreatedAt {
                return [
                    "page": page,
                    "limit": limit,
                    "lastCreatedAt": Self.iSO8601Formatter.string(from: lastCreatedAt),
                ]
            } else {
                return [
                    "page": page,
                    "limit": limit,
                ]
            }
        }

        AF.request(
            CommentService.baseURL + userId + "/\(postId)/comments/all",
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
