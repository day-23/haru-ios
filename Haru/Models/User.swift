//
//  User.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//
import Foundation

struct User: Hashable, Equatable, Identifiable, Codable {
    let id: String
    var name: String
    var introduction: String
    var profileImage: String?
    var postCount: Int
    var friendCount: Int
    var friendStatus: Int
    var isPublicAccount: Bool
}
