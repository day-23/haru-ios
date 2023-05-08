//
//  User.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//
import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var introduction: String
    var profileImage: String?
    var postCount: Int
    var followerCount: Int
    var followingCount: Int
}

//  MARK: - Extensions

extension User {
//    mutating func changeEmail(_ email: String) {
//        self.email = email
//    }
}
