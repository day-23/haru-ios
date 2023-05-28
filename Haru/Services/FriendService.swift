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
    
    func fetchFriend(
        userId: String,
        page: Int,
        completion: @escaping (Result<([User], Post.Pagination), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [User]
            let pagination: Post.Pagination
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "page": page,
        ]
        
        AF.request(
            Constants.baseURL + "follows" + (Global.shared.user?.id ?? "unknown") + "/\(userId)/following",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: JSONDecoder()) { response in
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
        completion: @escaping (Result<([User], Post.Pagination), Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [User]
            let pagination: Post.Pagination
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "page": page,
        ]
        
        AF.request(
            FriendService.baseURL + (Global.shared.user?.id ?? "unknown") + "/request",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let response):
                completion(.success((response.data, response.pagination)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestFriend(
        followId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "followId": followId,
        ]
        
        AF.request(
            Constants.baseURL + "follows" + (Global.shared.user?.id ?? "unknown") + "/follow",
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
    
    // requestId => 친구 신청 요청을 보낸 사용자
    func acceptRequestFriend(
        requestId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "requestId": requestId,
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
        followingId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "followingId": followingId,
        ]
        
        AF.request(
            Constants.baseURL + "follows" + (Global.shared.user?.id ?? "unknown") + "/following",
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
}