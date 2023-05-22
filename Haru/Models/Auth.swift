//
//  Auth.swift
//  Haru
//
//  Created by 이민재 on 2023/05/19.
//

import Foundation

struct UserKakaoAuthResponse: Codable {
    let success: Bool
    let data: UserKakaoAuth
}

struct UserKakaoAuth: Codable {
    let id: String
    let name: String
    let cookie: String
    let accessToken: String
    let refreshToken: String
}

struct UserVerifyResponse: Codable {
    let success: Bool
    let data: UserVerify
}

struct UserVerify: Codable {
    let id: String
    let accessToken: String
}


struct UserAppleAuthResponse: Codable {
    let success: Bool
    let data: UserAppleAuth
}

struct UserAppleAuth: Codable {
    let id: String
    let name: String
    let cookie: String
    let accessToken: String
    let refreshToken: String
}
