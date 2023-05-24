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
}

extension Me: Identifiable {
    var id: String {
        user.id
    }
}
