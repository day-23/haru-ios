//
//  FriendUser.swift
//  Haru
//
//  Created by 이준호 on 2023/05/31.
//

import Foundation

struct FriendUser: Hashable, Equatable, Identifiable, Codable {
    let id: String
    var name: String
    var profileImageUrl: String?
    var friendStatus: Int

    var createdAt: Date
}
