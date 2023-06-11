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
    var isTemplatePost: String?
    var images: [Image]
    var hashTags: [String]
    var isLiked: Bool
    var isCommented: Bool
    var likedCount: Int
    var commentCount: Int
    
    //  MARK: - Dates

    let createdAt: Date
    var updatedAt: Date?
    
    // MARK: - 프론트를 위한 필드

    var disabled: Bool = false // 숨기기, 삭제하기, 신고하기 눌렀을 때 게시물을 다시 불러오기 전까지 사용
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.user = try container.decode(Post.User.self, forKey: .user)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.isTemplatePost = try container.decodeIfPresent(String.self, forKey: .isTemplatePost)
        self.images = try container.decode([Post.Image].self, forKey: .images)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.isCommented = try container.decode(Bool.self, forKey: .isCommented)
        self.likedCount = try container.decode(Int.self, forKey: .likedCount)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}

extension Post {
    struct User: Identifiable, Codable {
        let id: String
        var name: String
        var profileImage: String? // 프로필 이미지 url 문자열
        var isAllowFeedLike: Int
        var isAllowFeedComment: Int
        var friendStatus: Int
    }
    
    struct Image: Identifiable, Codable {
        let id: String
        var originalName: String
        var url: String
        var mimeType: String
        var comments: [Comment]
    }
    
    struct Comment: Identifiable, Codable {
        struct User: Identifiable, Codable {
            let id: String
            var name: String
            var profileImage: String? // 프로필 이미지 url 문자열
        }
        
        let id: String
        var user: Comment.User
        var content: String
        var x: Double
        var y: Double
        var isPublic: Bool
        
        //  MARK: - Dates
        
        let createdAt: Date
        var updatedAt: Date?
        
        init(
            id: String,
            user: Comment.User,
            content: String,
            x: Double,
            y: Double,
            isPublic: Bool = true,
            createdAt: Date,
            updatedAt: Date? = nil
        ) {
            self.id = id
            self.user = user
            self.content = content
            self.x = x
            self.y = y
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            
            self.isPublic = isPublic
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.content = try container.decode(String.self, forKey: .content)
            self.x = try container.decode(Double.self, forKey: .x)
            self.y = try container.decode(Double.self, forKey: .y)
            self.createdAt = try container.decode(Date.self, forKey: .createdAt)
            self.updatedAt = (try? container.decode(Date.self, forKey: .updatedAt)) ?? nil
            
            self.isPublic = (try? container.decode(Bool.self, forKey: .isPublic)) ?? true
            self.user = (try? container.decode(Comment.User.self, forKey: .user)) ?? Comment.User(id: Global.shared.user?.id ?? "unknown", name: Global.shared.user?.user.name ?? "unknown")
        }
    }
    
    struct Pagination: Codable {
        let totalItems: Int
        let itemsPerPage: Int
        let currentPage: Int
        let totalPages: Int
    }
}
