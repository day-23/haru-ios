//
//  AuthService.swift
//  Haru
//
//  Created by 이민재 on 2023/05/19.
//

import Alamofire
import Foundation

struct AuthService {
    private static let baseURL = Constants.baseURL + "auth/"

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

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Constants.dateEncodingStrategy
        return encoder
    }()

    // MARK: - CREATE API

    func validateKakaoUserWithToken(
        token: String,
        completion: @escaping (Result<UserKakaoAuthResponse, Error>) -> Void
    ) {
        let headers: HTTPHeaders = ["authorization": "Bearer \(token)"]
        validateKakaoUser(headers: headers, completion: completion)
    }

    func validateKakaoUser(
        headers: HTTPHeaders,
        completion: @escaping (Result<UserKakaoAuthResponse, Error>) -> Void
    ) {
        AF.request(
            AuthService.baseURL + "kakao",
            method: .post,
            headers: headers
        ).responseDecodable(of: UserKakaoAuthResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 하루 서버에 최종 인증
    func validateUser(
        headers: HTTPHeaders,
        completion: @escaping (Result<Me, Error>) -> Void
    ) {
        struct Response: Codable {
            let success: Bool
            let data: Me
        }

        AFProxy.request(
            AuthService.baseURL + "verify-token",
            method: .post,
            headers: headers
        ).responseDecodable(of: Response.self, decoder: Self.decoder) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // apple login
    func validateAppleUserWithToken(
        token: String,
        completion: @escaping (Result<UserAppleAuthResponse, Error>) -> Void
    ) {
        let headers: HTTPHeaders = ["authorization": "Bearer \(token)"]
        validateAppleUser(headers: headers, completion: completion)
    }

    func validateAppleUser(
        headers: HTTPHeaders,
        completion: @escaping (Result<UserAppleAuthResponse, Error>) -> Void
    ) {
        AF.request(
            AuthService.baseURL + "apple",
            method: .post,
            headers: headers
        ).responseDecodable(of: UserAppleAuthResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func validateAppleUserWithAuthCode(
        authCode: String,
        completion: @escaping (Result<UserAppleAuthResponse, Error>) -> Void
    ) {
        let headers: HTTPHeaders = ["authCode": authCode]
        validateAppleUser(headers: headers, completion: completion)
    }
}
