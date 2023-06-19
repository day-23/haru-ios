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

    var disabled: Bool = false

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.friendStatus = try container.decode(Int.self, forKey: .friendStatus)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}
