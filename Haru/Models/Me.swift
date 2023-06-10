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
    var morningAlarmTime: Date?
    var nightAlarmTime: Date?
    var isScheduleAlarmOn: Bool
    let isMaliciousUser: Bool
    let createdAt: Date
    let accessToken: String

    init(user: User, haruId: String, email: String, socialAccountType: String, isPostBrowsingEnabled: Bool, isAllowFeedLike: Int, isAllowFeedComment: Int, isAllowSearch: Bool, isMaliciousUser: Bool, morningAlarmTime: Date?, nightAlarmTime: Date?, isScheduleAlarmOn: Bool, createdAt: Date, accessToken: String) {
        self.user = user
        self.haruId = haruId
        self.email = email
        self.socialAccountType = socialAccountType
        self.isPostBrowsingEnabled = isPostBrowsingEnabled
        self.isAllowFeedLike = isAllowFeedLike
        self.isAllowFeedComment = isAllowFeedComment
        self.isAllowSearch = isAllowSearch
        self.morningAlarmTime = morningAlarmTime
        self.nightAlarmTime = nightAlarmTime
        self.isScheduleAlarmOn = isScheduleAlarmOn
        self.isMaliciousUser = isMaliciousUser
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
        self.morningAlarmTime = try container.decodeIfPresent(Date.self, forKey: .morningAlarmTime)
        self.nightAlarmTime = try container.decodeIfPresent(Date.self, forKey: .nightAlarmTime)
        self.isScheduleAlarmOn = try container.decode(Bool.self, forKey: .isScheduleAlarmOn)
        self.isMaliciousUser = try container.decode(Bool.self, forKey: .isMaliciousUser)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken) ?? ""
    }

    enum CodingKeys: CodingKey {
        case user
        case haruId
        case email
        case socialAccountType
        case isPostBrowsingEnabled
        case isAllowFeedLike
        case isAllowFeedComment
        case isAllowSearch
        case morningAlarmTime
        case nightAlarmTime
        case isScheduleAlarmOn
        case isMaliciousUser
        case createdAt
        case accessToken
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.user, forKey: .user)
        try container.encode(self.haruId, forKey: .haruId)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.socialAccountType, forKey: .socialAccountType)
        try container.encode(self.isPostBrowsingEnabled, forKey: .isPostBrowsingEnabled)
        try container.encode(self.isAllowFeedLike, forKey: .isAllowFeedLike)
        try container.encode(self.isAllowFeedComment, forKey: .isAllowFeedComment)
        try container.encode(self.isAllowSearch, forKey: .isAllowSearch)
        try container.encode(self.morningAlarmTime, forKey: .morningAlarmTime)
        try container.encode(self.nightAlarmTime, forKey: .nightAlarmTime)
        try container.encode(self.isScheduleAlarmOn, forKey: .isScheduleAlarmOn)
        try container.encode(self.isMaliciousUser, forKey: .isMaliciousUser)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.accessToken, forKey: .accessToken)
    }
}

extension Me: Identifiable {
    var id: String {
        self.user.id
    }
}
