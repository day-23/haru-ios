//
//  ProfileService.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//  Updated by 최정민 on 2023/06/09.
//

import Alamofire
import Foundation
import UIKit

struct ProfileService {
    enum ProfileError: Error {
        case duplicated
        case badname
        case invalid
    }

    private static let baseURL = Constants.baseURL + "post/"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Self.formatter)
        return decoder
    }()

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
        .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
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

        AF.upload(
            multipartFormData: { multipartFormData in
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
        .responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     * 초기에 유저 정보가 입력될 때 호출 (이미지 포함)
     */
    func initUserProfileWithImage(
        userId: String,
        name: String,
        haruId: String,
        profileImage: UIImage,
        completion: @escaping (Result<Me, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Me
        }

        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=Boundary-\(UUID().uuidString)",
        ]

        let params: Parameters = [
            "name": name,
            "haruId": haruId,
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                if let image = profileImage.jpegData(compressionQuality: 1) {
                    multipartFormData.append(image, withName: "image", fileName: "\(image).jpeg", mimeType: "image/jpeg")
                }
                for (key, value) in params {
                    if let data = value as? String {
                        multipartFormData.append(data.data(using: .utf8)!, withName: key)
                    }
                }
            },
            to: ProfileService.baseURL + "\(userId)/profile/image/init",
            usingThreshold: .init(),
            method: .patch,
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

    /**
     * 초기에 유저 정보가 입력될 때 호출 (이미지 제외)
     */
    func initUserProfileWithoutImage(
        userId: String,
        name: String,
        haruId: String,
        completion: @escaping (Result<Me, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Me
        }

        struct ResponseError: Codable {
            let success: Bool
            let error: Data

            struct Data: Codable {
                let code: Int
                let message: String
            }
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: Parameters = [
            "name": name,
            "haruId": haruId,
        ]

        AF.request(
            ProfileService.baseURL + "\(userId)/profile/init",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .responseDecodable(
            of: Response.self, decoder: Self.decoder
        ) { response in
            switch response.result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 403:
                        completion(.failure(ProfileError.badname))
                    case 409:
                        completion(.failure(ProfileError.duplicated))
                    default:
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    // 아이디 중복 검사
    func validateHaruId(
        haruId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]

        let params: Parameters = [
            "haruId": haruId,
        ]

        AF.request(
            ProfileService.baseURL + "\(Global.shared.user?.id ?? "unknown")/profile/init/haruId",
            method: .patch,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .responseDecodable(
            of: Response.self, decoder: Self.decoder
        ) { response in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 409:
                        completion(.failure(ProfileError.duplicated))
                    default:
                        break
                    }
                }
                completion(.success(true))
            case let .failure(error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 409:
                        completion(.failure(ProfileError.duplicated))
                    default:
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
