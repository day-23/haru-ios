//
//  FallowService.swift
//  Haru
//
//  Created by 이준호 on 2023/05/09.
//

import Alamofire
import Foundation

final class FriendService {
    private static let baseURL = Constants.baseURL + "friends/"
    
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
        decoder.dateDecodingStrategy = .formatted(FriendService.formatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()
    
    func fetchFriend(
        userId: String,
        page: Int,
        completion: @escaping (Result<([FriendUser], Post.Pagination), Error>) -> Void
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
            "page": page,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown") + "/\(userId)",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success(let response):
                completion(.success((response.data, response.pagination)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRequestFriend(
        userId: String,
        page: Int,
        completion: @escaping (Result<([FriendUser], Post.Pagination), Error>) -> Void
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
            "page": page,
        ]
        
        AF.request(
            FriendService.baseURL + "\(userId)" + "/request",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success(let response):
                completion(.success((response.data, response.pagination)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestFriend(
        acceptorId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "acceptorId": acceptorId,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown") + "/request",
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
        .response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // requesterId => 친구 신청 요청을 보낸 사용자
    func acceptRequestFriend(
        requesterId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "requesterId": requesterId,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown") + "/accept",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelRequestFriend(
        acceptorId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "acceptorId": acceptorId,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown") + "/request",
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteFriend(
        friendId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "friendId": friendId,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown"),
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func blockFriend(
        blockUserId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "blockUserId": blockUserId,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown") + "/block",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
