//
//  Post.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    var user: Post.User
    var content: String?
    var templateUrl: String?
    var images: [Image]
    var hashTags: [String]
    var isLiked: Bool
    var isCommented: Bool
    var likedCount: Int
    var commentCount: Int
    
    //  MARK: - Dates

    let createdAt: Date
    var updatedAt: Date?
    
    struct User: Identifiable, Codable {
        let id: String
        var name: String
        var profileImage: String? // 프로필 이미지 url 문자열
    }
    
    struct Image: Identifiable, Codable {
        let id: String
        var originalName: String
        var url: String
        var mimeType: String
        var comments: [Comment]
    }
    
    struct Comment: Identifiable, Codable {
        let id: String
        var user: Post.User
        var content: String
        var x: Double
        var y: Double
        
        //  MARK: - Dates
        
        let createdAt: Date
        var updatedAt: Date?
        
        init(id: String, user: Post.User, content: String, x: Double, y: Double, createdAt: Date, updatedAt: Date? = nil) {
            self.id = id
            self.user = user
            self.content = content
            self.x = x
            self.y = y
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            content = try container.decode(String.self, forKey: .content)
            x = try container.decode(Double.self, forKey: .x)
            y = try container.decode(Double.self, forKey: .y)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            updatedAt = (try? container.decode(Date.self, forKey: .updatedAt)) ?? nil
            
            user = (try? container.decode(Post.User.self, forKey: .user)) ?? Post.User(id: Global.shared.user?.id ?? "unknown", name: Global.shared.user?.user.name ?? "unknown")
        }
    }
    
    struct Pagination: Codable {
        let totalItems: Int
        let itemsPerPage: Int
        let currentPage: Int
        let totalPages: Int
    }
}
