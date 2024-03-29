//
//  PostService.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import Alamofire
import Foundation
import SwiftUI
import UIKit

final class PostService {
    enum PostError: Error {
        case badword
        case tooManyPost
    }

    private static let baseURL = Constants.baseURL + "post/"

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
        decoder.dateDecodingStrategy = .formatted(PostService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    private init() {}

    // MARK: - 게시물 불러오기

    public static func fetchFreindPosts(
        page: Int,
        limit: Int = 5,
        lastCreatedAt: Date?,
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

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/posts/follow/feed",
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

    public static func fetchTargetPosts(
        targetId: String,
        page: Int,
        limit: Int = 5,
        lastCreatedAt: Date?,
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

        AFProxy.request(
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

    // 둘러보기 전체 게시물 불러오기
    public static func fetchAllMedia(
        page: Int,
        limit: Int = 12,
        lastCreatedAt: Date?,
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

        AFProxy.request(
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

    // 둘러보기 해시태그 게시물 불러오기
    public static func fetchMediaHashTag(
        hashTagId: String,
        page: Int,
        limit: Int = 12,
        lastCreatedAt: Date?,
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

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/posts/hashtag/\(hashTagId)/",
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

    // 특정 사용자 미디어 전체보기
    public static func fetchTargetMediaAll(
        targetId: String,
        page: Int,
        limit: Int = 12,
        lastCreatedAt: Date?,
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

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/posts/user/\(targetId)/media",
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

    public static func fetchTargetMediaHashTag(
        targetId: String,
        hashTagId: String,
        page: Int,
        limit: Int = 12,
        lastCreatedAt: Date?,
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

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/posts/user/\(targetId)/media/hashtag/\(hashTagId)",
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

    // MARK: - 게시물 추가, 수정, 삭제

    public static func createPostWithImages(
        imageList: [UIImage],
        content: String,
        tagList: [Tag],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // TODO: 나중에 Respose.Post 리팩토링 해주기
        struct Response: Codable {
            let success: Bool
            let data: Post

            struct Post: Codable {
                let id: String
                let images: [Image]
                let hashTags: [String]
                let content: String
                let templateUrl: String?
                let createdAt: Date?
                let updatedAt: Date?

                init(from decoder: Decoder) throws {
                    let container: KeyedDecodingContainer<Response.Post.CodingKeys> = try decoder.container(keyedBy: Response.Post.CodingKeys.self)
                    self.id = try container.decode(String.self, forKey: Response.Post.CodingKeys.id)
                    self.images = try container.decode([Response.Image].self, forKey: Response.Post.CodingKeys.images)

                    var hashTags: [String] = []
                    do {
                        let hashTag = try container.decode(String.self, forKey: Response.Post.CodingKeys.hashTags)
                        hashTags = [hashTag]
                    } catch {}
                    if hashTags.isEmpty {
                        hashTags = try container.decode([String].self, forKey: Response.Post.CodingKeys.hashTags)
                    }
                    self.hashTags = hashTags
                    self.content = try container.decode(String.self, forKey: Response.Post.CodingKeys.content)
                    self.templateUrl = try container.decodeIfPresent(String.self, forKey: Response.Post.CodingKeys.templateUrl)
                    self.createdAt = try container.decodeIfPresent(Date.self, forKey: Response.Post.CodingKeys.createdAt)
                    self.updatedAt = try container.decodeIfPresent(Date.self, forKey: Response.Post.CodingKeys.updatedAt)
                }
            }

            struct Image: Codable {
                let id: String
                var originalName: String
                var url: String
                var mimeType: String
                var comments: [String]

                init(from decoder: Decoder) throws {
                    let container: KeyedDecodingContainer<Response.Image.CodingKeys> = try decoder.container(keyedBy: Response.Image.CodingKeys.self)
                    self.id = try container.decode(String.self, forKey: Response.Image.CodingKeys.id)
                    self.originalName = try container.decode(String.self, forKey: Response.Image.CodingKeys.originalName)
                    self.url = try container.decode(String.self, forKey: Response.Image.CodingKeys.url)
                    self.mimeType = try container.decode(String.self, forKey: Response.Image.CodingKeys.mimeType)
                    self.comments = try container.decode([String].self, forKey: Response.Image.CodingKeys.comments)
                }
            }
        }

        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=Boundary-\(UUID().uuidString)",
        ]

        let parameters: Parameters = [
            "content": content,
            "hashTags": tagList,
        ]

        withAnimation {
            Global.shared.isLoading = true
        }

        AFProxy.upload(multipartFormData: { multipartFormData in
                           for postImage in imageList {
                               if let image = postImage.jpegData(compressionQuality: 1) {
                                   multipartFormData.append(image, withName: "images", fileName: "\(image).jpeg", mimeType: "image/jpeg")
                               }
                           }

                           for (key, value) in parameters {
                               if let data = value as? String {
                                   multipartFormData.append(data.data(using: .utf8)!, withName: key)
                               } else if let dataList = value as? [Tag] {
                                   for data in dataList {
                                       multipartFormData.append(data.content.data(using: .utf8)!, withName: key)
                                   }
                               }
                           }
                       },
                       to: PostService.baseURL + "\(Global.shared.user?.id ?? "unknown")",
                       usingThreshold: .init(),
                       method: .post,
                       headers: headers)
            .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
                switch response.result {
                case .success:
                    completion(.success(true))
                case let .failure(error):
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 403:
                            completion(.failure(PostError.badword))
                        case 429:
                            completion(.failure(PostError.tooManyPost))
                        default:
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }

                withAnimation {
                    Global.shared.isLoading = false
                }
            }
    }

    public static func createPostWithTemplate(
        templateId: String,
        templateTextColor: String,
        content: String,
        tagList: [Tag],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "templateId": templateId,
            "templateTextColor": templateTextColor,
            "content": content,
            "hashTags": tagList.map { tag in
                tag.content
            },
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/template",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 403:
                        completion(.failure(PostError.badword))
                        return
                    case 429:
                        completion(.failure(PostError.tooManyPost))
                        return
                    default:
                        break
                    }
                }
                completion(.success(true))
            case let .failure(error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 403:
                        completion(.failure(PostError.badword))
                    case 429:
                        completion(.failure(PostError.tooManyPost))
                    default:
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    public static func deletePost(
        postId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(postId)",
            method: .delete,
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

    public static func hidePost(
        postId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(postId)/hide",
            method: .post,
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

    public static func reportPost(
        postId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(postId)/report",
            method: .post,
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

    // MARK: - 게시물 부수적인 기능

    // 서버에 있는 기본 템플릿 불러오기
    // TODO: ProfileImage 모델 이름에서 다른 이름으로 바꿔주기
    public static func fetchTemplate(completion: @escaping (Result<[ProfileImage], Error>) -> Void) {
        struct Response: Codable {
            let success: Bool
            let data: [ProfileImage]
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/template",
            method: .get,
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

    // 인기 해시태그 불러오기
    public static func fetchPopularHashTags(
        completion: @escaping (Result<[HashTag], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [HashTag]
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/hashtags/",
            method: .get,
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

    // 사용자 해시태그 불러오기
    public static func fetchTargetHashTags(
        targetId: String,
        completion: @escaping (Result<[HashTag], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [HashTag]
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/hashtags/\(targetId)",
            method: .get,
            encoding: URLEncoding.default,
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

    public static func likeThisPost(
        targetPostId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=Boundary-\(UUID().uuidString)",
        ]

        AFProxy.request(
            PostService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(targetPostId)/like",
            method: .post,
            encoding: URLEncoding.default,
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
