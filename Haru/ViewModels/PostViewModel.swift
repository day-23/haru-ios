//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation

final class PostViewModel: ObservableObject {
    @Published var postList: [Post] = []
    @Published var page: Int = 1

    var postOption: PostOption

    private let postService: PostService

    init(postOption: PostOption) {
        self.postOption = postOption
        postService = .init()
    }

    func loadMorePosts(targetId: String? = nil) {
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

    func fetchAllPosts() {
        postService.fetchAllPosts(page: page) { result in
            switch result {
            case .success(let success):
                self.postList = success.0
//                let pageInfo = success.1
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetPosts(targetId: String) {
        postService.fetchTargetPosts(targetId: targetId, page: page) { result in
            switch result {
            case .success(let success):
                self.postList = success.0
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
