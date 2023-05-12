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
        .responseDecodable(of: Response.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     * 유저 프로필 변경 사진과 함께
     */
    func updateUserProfileWithImage(
        userId: String,
        name: String,
        introduction: String,
        profileImage: UIImage,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: User
        }

        // TODO: 코드 작성해주기
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=Boundary-\(UUID().uuidString)",
        ]

        let parameters: Parameters = [
            "name": name,
            "introduction": introduction,
        ]

        AF.upload(multipartFormData: { multipartFormData in
                      if let image = profileImage.jpegData(compressionQuality: 1) {
                          multipartFormData.append(image, withName: "image", fileName: "\(image).jpeg", mimeType: "image/jpeg")
                      }
                      for (key, value) in parameters {
                          if let data = value as? String {
                              multipartFormData.append(data.data(using: .utf8)!, withName: key)
                          }
                      }
                  },
                  to: ProfileService.baseURL + "\(userId)/profile/image",
                  usingThreshold: .init(),
                  method: .patch,
                  headers: headers)
            .responseDecodable(of: Response.self, decoder: JSONDecoder()) { response in
                switch response.result {
                case let .success(response):
                    completion(.success(response.data))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    /**
     * 유저 프로필 사진은 변경하지 않은 경우
     */
    func updateUserProfileWithoutImage(
        userId: String,
        name: String,
        introduction: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: User
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let parameters: Parameters = [
            "name": name,
            "introduction": introduction,
        ]

        AF.request(
            ProfileService.baseURL + "\(userId)/profile",
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .responseDecodable(of: Response.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
