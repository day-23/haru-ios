//
//  CommentViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/29.
//

import Foundation
import UIKit

final class CommentViewModel: ObservableObject {
    var userId: String // 게시물 작성자 id
    var postId: String // 게시물 id
    var postImageIDList: [Post.Image.ID] // 게시물의 이미지들
    var templateURL: String? //
    @Published var imagePageNum: Int
    
    @Published var imageCommentList: [Post.Image.ID: [Post.Comment]]
    @Published var imageCommentUserProfileUrlList: [Post.Image.ID: [URL?]]
    
    var page: Int {
        guard let commentList = imageCommentList[postImageIDList[imagePageNum]] else {
            return 1
        }
        
        return Int(ceil(Double(commentList.count) / 10.0)) + 1
    }
    
    var commentTotalPage: [Post.Image.ID: Int] = [:]
    
    var lastCreatedAt: Date? {
        imageCommentList[postImageIDList[imagePageNum]]?.first?.createdAt
    }
    
    @Published var commentTotalCount: [Post.Image.ID: Int] = [:]
    
    init(
        userId: String,
        postImageIDList: [Post.Image.ID],
        postId: String,
        templateURL: String? = nil,
        imagePageNum: Int
    ) {
        self.userId = userId
        self.postImageIDList = postImageIDList
        self.postId = postId
        self.templateURL = templateURL
        self.imagePageNum = imagePageNum
        
        self.imageCommentList = postImageIDList.reduce(into: [String: [Post.Comment]]()) { dictionary, element in
            dictionary[element] = []
        }
        
        self.imageCommentUserProfileUrlList = postImageIDList.reduce(into: [String: [URL?]]()) { dictionary, element in
            dictionary[element] = []
        }
    }
    
    func initLoad(isTemplate: Bool = false) {
        if isTemplate {
            loadMoreComments(isTemplate: isTemplate)
            return
        }
        
        for imageId in postImageIDList {
            fetchTargetImageComment(
                userId: userId,
                postId: postId,
                imageId: imageId,
                page: 1,
                lastCreatedAt: nil
            )
        }
    }
    
    func loadMoreComments(isTemplate: Bool = false) {
        if let commentTotalPage = commentTotalPage[postImageIDList[imagePageNum]] {
            if page > commentTotalPage {
                print("[Error] 더 이상 불러올 게시물이 없습니다")
                print("\(#function) \(#fileID)")
                return
            }
        }
        if !isTemplate {
            fetchTargetImageComment(
                userId: userId,
                postId: postId,
                imageId: postImageIDList[imagePageNum],
                page: page,
                lastCreatedAt: lastCreatedAt
            )
        } else {
            fetchTargetTemplateComment(
                userId: userId,
                postId: postId,
                imageId: postImageIDList[imagePageNum],
                page: page,
                lastCreatedAt: lastCreatedAt
            )
        }
    }

    // MARK: - 서버와 API 연동
    
    func fetchTargetImageComment(
        userId: String,
        postId: String,
        imageId: String,
        page: Int,
        lastCreatedAt: Date?
    ) {
        CommentService.fetchTargetImageComment(
            userId: userId,
            postId: postId,
            imageId: imageId,
            page: page,
            lastCreatedAt: lastCreatedAt
        ) { result in
            switch result {
            case .success(let success):
                self.imageCommentUserProfileUrlList[imageId]?.append(
                    contentsOf: success.0.map {
                        if let url = $0.user.profileImage {
                            return URL.encodeURL(url)
                        } else {
                            return nil
                        }
                    }
                )
            
                self.imageCommentList[imageId] = (self.imageCommentList[imageId] ?? []) + success.0
                
                let pageInfo = success.1
                
                if self.commentTotalPage[imageId] == nil {
                    self.commentTotalPage[imageId] = pageInfo.totalPages
                    self.commentTotalCount[imageId] = pageInfo.totalItems
                }
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func fetchTargetTemplateComment(
        userId: String,
        postId: String,
        imageId: String,
        page: Int,
        lastCreatedAt: Date?
    ) {
        CommentService.fetchTargetTemplateComment(
            userId: userId,
            postId: postId,
            page: page,
            lastCreatedAt: lastCreatedAt
        ) { result in
            switch result {
            case .success(let success):
                self.imageCommentUserProfileUrlList[imageId]?.append(
                    contentsOf: success.0.map {
                        if let url = $0.user.profileImage {
                            return URL.encodeURL(url)
                        } else {
                            return nil
                        }
                    }
                )
            
                self.imageCommentList[imageId] = (self.imageCommentList[imageId] ?? []) + success.0
                
                let pageInfo = success.1
                
                if self.commentTotalPage[imageId] == nil {
                    self.commentTotalPage[imageId] = pageInfo.totalPages
                    self.commentTotalCount[imageId] = pageInfo.totalItems
                }
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func updateCommentPublic(
        userId: String,
        commentId: String,
        isPublic: Bool,
        imageId: String,
        idx: Int
    ) {
        let request = Request.Comment(isPublic: isPublic)
        
        CommentService.updateComment(targetUserId: userId, targetCommentId: commentId, comment: request) { result in
            switch result {
            case .success:
                self.imageCommentList[imageId]?[idx].isPublic = isPublic
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func deleteComment(
        userId: String,
        commentId: String,
        imageId: String
    ) {
        CommentService.deleteComment(targetUserId: userId, targetCommentId: commentId) { result in
            switch result {
            case .success:
                let tmpPage = self.page
                self.clear()
                for _ in 0 ..< tmpPage {
                    self.loadMoreComments()
                }
                
                if self.commentTotalCount[imageId] != nil {
                    self.commentTotalCount[imageId]! -= 1
                }
                
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func clear() {
        imageCommentList = postImageIDList.reduce(into: [String: [Post.Comment]]()) { dictionary, element in
            dictionary[element] = []
        }
        
        imageCommentUserProfileUrlList = postImageIDList.reduce(into: [String: [URL?]]()) { dictionary, element in
            dictionary[element] = []
        }
    }
}
