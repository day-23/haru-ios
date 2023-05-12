//
//  PostService.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import Alamofire
import Foundation
import UIKit

final class PostService {
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

    func fetchFreindPosts(
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

        AF.request(
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

    func fetchTargetPosts(
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

    func createPostWithImages(
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
            }

            struct Image: Codable {
                let id: String
                var originalName: String
                var url: String
                var mimeType: String
                var comments: [String]
            }
        }

        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=Boundary-\(UUID().uuidString)",
        ]

        let parameters: Parameters = [
            "content": content,
            "hashTags": tagList,
        ]

        AF.upload(multipartFormData: { multipartFormData in
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
                    completion(.failure(error))
                }
            }
    }

    func createPostWithTemplate() {}

    func likeThisPost(
        targetPostId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=Boundary-\(UUID().uuidString)",
        ]

        AF.request(
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
