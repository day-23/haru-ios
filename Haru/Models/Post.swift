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
        var x: Int
        var y: Int
        
        //  MARK: - Dates
        
        let createdAt: Date
        var updatedAt: Date?
    }
    
    struct Pagination: Codable {
        let totalItems: Int
        let itemsPerPage: Int
        let currentPage: Int
        let totalPages: Int
    }
}
