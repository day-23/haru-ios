//
//  CommentViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/29.
//

import Foundation

final class CommentViewModel: ObservableObject {
    var userId: String // 게시물 작성자 id
    var postId: String // 게시물 id
    var postImageIDList: [Post.Image.ID] // 게시물의 이미지
    @Published var imagePageNum: Int
    
    @Published var imageCommentList: [Post.Image.ID: [Post.Comment]] = [:]
    
    var page: Int {
        guard let commentList = imageCommentList[postImageIDList[imagePageNum]] else {
            return 1
        }
        
        return Int(ceil(Double(commentList.count) / 20.0)) + 1
    }
    
    var commentTotalPage: [Post.Image.ID: Int] = [:]
    
    var lastCreatedAt: Date? {
        imageCommentList[postImageIDList[imagePageNum]]?.first?.createdAt
    }
    
    private let commentService: CommentService
    
    init(
        userId: String,
        postImageIDList: [Post.Image.ID],
        postId: String,
        imagePageNum: Int
    ) {
        self.userId = userId
        self.postImageIDList = postImageIDList
        self.postId = postId
        self.imagePageNum = imagePageNum
        commentService = .init()
    }
    
    func loadMoreComments() {
        if let commentTotalPage = commentTotalPage[postImageIDList[imagePageNum]] {
            if page > commentTotalPage {
                print("[Error] 더 이상 불러올 게시물이 없습니다")
                print("\(#function) \(#fileID)")
                return
            }
        }
        
        fetchTargetImageComment(
            userId: userId,
            postId: postId,
            imageId: postImageIDList[imagePageNum],
            page: page,
            lastCreatedAt: lastCreatedAt
        )
    }
    
    func fetchTargetImageComment(
        userId: String,
        postId: String,
        imageId: String,
        page: Int,
        lastCreatedAt: Date?
    ) {
        commentService.fetchTargetImageComment(
            userId: userId,
            postId: postId,
            imageId: imageId,
            page: page,
            lastCreatedAt: lastCreatedAt
        ) { result in
            switch result {
            case .success(let success):
                self.imageCommentList[imageId] = (self.imageCommentList[imageId] ?? []) + success.0
                
                let pageInfo = success.1
                
                if self.commentTotalPage[imageId] == nil {
                    self.commentTotalPage[imageId] = pageInfo.totalPages
                }
                
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
