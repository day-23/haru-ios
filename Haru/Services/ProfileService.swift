//
//  ProfileService.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Alamofire
import Foundation

struct ProfileService {
    private static let baseURL = Constants.baseURL + "post/"

    /**
     * 프로필 사진 가져오기
     */
    func fetchProfileImage(
        userId: String,
        completion: @escaping (Result<[ProfileImage], Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: [ProfileImage]
        }

        AF.request(
            ProfileService.baseURL + userId + "/profile/images",
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
}
