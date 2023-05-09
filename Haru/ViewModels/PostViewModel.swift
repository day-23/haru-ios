//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation

final class PostViewModel: ObservableObject {
    @Published var postList: [Post] = []

    private let postService: PostService = .init()

    func fetchAllPosts(currentPage: Int) {
        postService.fetchAllPosts(page: currentPage) { result in
            switch result {
            case .success(let success):
                self.postList = success.0
//                let pageInfo = success.1
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetPosts(targetId: String, currentPage: Int) {
        postService.fetchTargetPosts(targetId: targetId, page: currentPage) { result in
            switch result {
            case .success(let success):
                self.postList = success.0
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
