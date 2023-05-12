//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation

final class PostViewModel: ObservableObject {
    @Published var postList: [Post] = []

    var page: Int = 1
    var totalPages: Int = 0

    var postOption: PostOption
    var targetId: String?

    private let postService: PostService

    init(postOption: PostOption, targetId: String? = nil) {
        self.postOption = postOption
        self.targetId = targetId
        postService = .init()

        switch postOption {
        case .main:
            fetchAllPosts()
        case .target_all:
            guard let targetId else { return }
            fetchTargetPosts(targetId: targetId)
        case .target_image:
            print("특정 사용자 미디어 보기")
        case .target_hashtag:
            print("특정 사용자 해시태그 조회")
        case .around:
            print("둘러보기")
        }
    }

    func loadMorePosts() {
        if (page + 1) > totalPages {
            return
        }
        page += 1
        switch postOption {
        case .main:
            fetchAllPosts()
        case .target_all:
            guard let targetId else { return }
            fetchTargetPosts(targetId: targetId)
        case .target_image:
            print("특정 사용자 미디어 보기")
        case .target_hashtag:
            print("특정 사용자 해시태그 조회")
        case .around:
            print("둘러보기")
        }
    }

    func refreshPosts() {
        clear()
        loadMorePosts()
    }

    func fetchAllPosts() {
        postService.fetchAllPosts(page: page) { result in
            switch result {
            case .success(let success):
                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.totalPages = pageInfo.totalPages
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetPosts(targetId: String) {
        postService.fetchTargetPosts(targetId: targetId, page: page) { result in
            switch result {
            case .success(let success):
                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.totalPages = pageInfo.totalPages
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func likeThisPost(targetPostId: String) {
        postService.likeThisPost(targetPostId: targetPostId) { result in
            switch result {
            case .success:
                for (idx, post) in self.postList.enumerated() {
                    if post.id != targetPostId {
                        continue
                    }
                    if post.isLiked {
                        self.postList[idx].likedCount -= 1
                        self.postList[idx].isLiked = false
                    } else {
                        self.postList[idx].likedCount += 1
                        self.postList[idx].isLiked = true
                    }
                }
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func clear() {
        page = 0
        postList = []
    }
}
