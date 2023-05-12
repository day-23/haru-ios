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
    var profileImage: String?
    var introduction: String
    var isFollowing: Bool
    var postCount: Int
    var followerCount: Int
    var followingCount: Int

    var email: String

    init(
        id: String,
        name: String,
        introduction: String,
        postCount: Int,
        followerCount: Int,
        followingCount: Int,
        isFollowing: Bool
    ) {
        self.id = id
        self.name = name
        self.introduction = introduction
        self.postCount = postCount
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.isFollowing = isFollowing
        email = "unknown@email.com"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profileImage = (try? container.decode(String.self, forKey: .profileImage)) ?? nil

        introduction = (try? container.decode(String.self, forKey: .introduction)) ?? ""
        email = (try? container.decode(String.self, forKey: .email)) ?? "unknown@email.com"
        isFollowing = (try? container.decode(Bool.self, forKey: .isFollowing)) ?? false
        postCount = (try? container.decode(Int.self, forKey: .postCount)) ?? 0
        followerCount = (try? container.decode(Int.self, forKey: .followerCount)) ?? 0
        followingCount = (try? container.decode(Int.self, forKey: .followingCount)) ?? 0
    }
}
