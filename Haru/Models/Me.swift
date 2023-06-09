//
//  Me.swift
//  Haru
//
//  Created by 최정민 on 2023/05/25.
//

import Foundation

struct Me: Codable {
    var user: User

    var haruId: String
    var email: String
    var socialAccountType: String
    var isPostBrowsingEnabled: Bool
    var isAllowFeedLike: Int
    var isAllowFeedComment: Int
    var isAllowSearch: Bool
    let createdAt: Date
    let accessToken: String

    init(user: User, haruId: String, email: String, socialAccountType: String, isPostBrowsingEnabled: Bool, isAllowFeedLike: Int, isAllowFeedComment: Int, isAllowSearch: Bool, createdAt: Date, accessToken: String) {
        self.user = user
        self.haruId = haruId
        self.email = email
        self.socialAccountType = socialAccountType
        self.isPostBrowsingEnabled = isPostBrowsingEnabled
        self.isAllowFeedLike = isAllowFeedLike
        self.isAllowFeedComment = isAllowFeedComment
        self.isAllowSearch = isAllowSearch
        self.createdAt = createdAt
        self.accessToken = accessToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decode(User.self, forKey: .user)
        self.haruId = try container.decodeIfPresent(String.self, forKey: .haruId) ?? ""
        self.email = try container.decode(String.self, forKey: .email)
        self.socialAccountType = try container.decode(String.self, forKey: .socialAccountType)
        self.isPostBrowsingEnabled = try container.decode(Bool.self, forKey: .isPostBrowsingEnabled)
        self.isAllowFeedLike = try container.decode(Int.self, forKey: .isAllowFeedLike)
        self.isAllowFeedComment = try container.decode(Int.self, forKey: .isAllowFeedComment)
        self.isAllowSearch = try container.decode(Bool.self, forKey: .isAllowSearch)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken) ?? ""
    }
}

extension Me: Identifiable {
    var id: String {
        self.user.id
    }
}
