//
//  ProfileService.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Alamofire
import Foundation
import UIKit

struct ProfileService {
    private static let baseURL = Constants.baseURL + "post/"

    /**
     * 유저 프로필 정보 가져오기
     */
    func fetchUserProfile(
        userId: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: User
        }

        AF.request(
            ProfileService.baseURL + (Global.shared.user?.id ?? "unknown") + "/info" + "/\(userId)",
            method: .get
        )
        .responseDecodable(of: Response.self) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     * 유저 프로필 변경
     */
    func updateUserProfile(
        userId: String,
        name: String,
        introduction: String,
        profileImage: UIImage?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // TODO: multipart-form 사용해서 update 요청할 것
    }
}
