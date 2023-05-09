//
//  FallowService.swift
//  Haru
//
//  Created by 이준호 on 2023/05/09.
//

import Alamofire
import Foundation

final class FollowService {
    private static let baseURL = Constants.baseURL + "follows/"
    
//    func fetchFollower(
//        userId: String,
//        page: Int,
//        completion: @escaping (Result<User, >)
//    )
    
    func addFollowing(
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
            FollowService.baseURL + (Global.shared.user?.id ?? "unknown") + "/follow",
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
    
    func cancelFollowing(
        followingId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "followingId": followingId
        ]
        
        AF.request(
            FollowService.baseURL + (Global.shared.user?.id ?? "unknown") + "/following",
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
    
    func deleteFollower(
        followId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        
        let parameters: Parameters = [
            "followId": followId
        ]
        
        AF.request(
            FollowService.baseURL + (Global.shared.user?.id ?? "unknown") + "/follow",
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
