//
//  ApiRequestInterceptor.swift
//  Haru
//
//  Created by 최정민 on 2023/06/16.
//

import Alamofire
import Foundation

final class ApiRequestInterceptor: RequestInterceptor {
    enum RequestError: Error {
        case invalidURL
        case decode
        case guest
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
//        guard urlRequest.url?.absoluteString.hasPrefix("https://api.23haru.com/") == true else {
//            completion(.failure(RequestError.invalidURL))
//            return
//        }

        if Global.shared.user?.id == "guest" {
            completion(.failure(RequestError.guest))
            return
        }

        guard let rawAccessToken = KeychainService.load(key: "accessToken") else {
            // 엑세스 토큰 경우, 로그인, OAuth 회원 가입시 (유저 정보 기입하는 화면 아님)
            completion(.success(urlRequest))
            return
        }

        guard let accessToken = String(data: rawAccessToken, encoding: .utf8) else {
            completion(.failure(RequestError.decode))
            return
        }

        var urlRequest = urlRequest
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {}
}
