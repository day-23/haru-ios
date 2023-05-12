//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation
import SwiftUI

final class PostViewModel: ObservableObject {
    @Published var postList: [Post] = []
    @Published var postImageList: [Post.ID: [PostImage?]] = [:]
    @Published var profileImage: PostImage?
    @Published var firstTimeAppear: Bool = true // 처음인지 아닌지 확인

    var page: Int = 1
    var totalPages: Int = 0

    var postOption: PostOption
    var targetId: String?

    private let postService: PostService

    init(postOption: PostOption, targetId: String? = nil) {
        self.postOption = postOption
        self.targetId = targetId
        postService = .init()
    }

    func loadMorePosts() {
        print("[Debug] pageNation 시작 \(postOption)")
        print("\(#fileID) \(#function)")

        if !firstTimeAppear {
            if (page + 1) > totalPages {
                return
            }
            page += 1
        }

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

        firstTimeAppear = false
    }

    func refreshPosts() {
        clear()
        loadMorePosts()
    }

    // MARK: - UIImage로 변환 + 이미지 캐싱

    func fetchPostImage(postId: String, postImages: [Post.Image]) {
        DispatchQueue.global().async {
            postImages.enumerated().forEach { idx, postImage in
                if let uiImage = ImageCache.shared.object(forKey: postImage.url as NSString) {
                    DispatchQueue.main.async {
                        self.postImageList[postId]?[idx] = PostImage(url: postImage.url, uiImage: uiImage)
                    }
                } else {
                    guard
                        let url = URL(string: postImage.url.encodeUrl()!),
                        let data = try? Data(contentsOf: url),
                        let uiImage = UIImage(data: data)
                    else {
                        print("[Error] \(postImage.url)이 잘못됨 \(#fileID) \(#function)")
                        return
                    }

                    ImageCache.shared.setObject(uiImage, forKey: postImage.url as NSString)
                    DispatchQueue.main.async {
                        self.postImageList[postId]?[idx] = PostImage(url: postImage.url, uiImage: uiImage)
                    }
                }
            }
        }
    }

    func fetchProfileImage(profileUrl: String) {
        DispatchQueue.global().async {
            if let uiImage = ImageCache.shared.object(forKey: profileUrl as NSString) {
                DispatchQueue.main.async {
                    self.profileImage = PostImage(url: profileUrl, uiImage: uiImage)
                }
            } else {
                guard
                    let encodeUrl = profileUrl.encodeUrl(),
                    let url = URL(string: encodeUrl),
                    let data = try? Data(contentsOf: url),
                    let uiImage = UIImage(data: data)
                else {
                    print("[Error] \(profileUrl)이 잘못됨 \(#fileID) \(#function)")
                    return
                }

                ImageCache.shared.setObject(uiImage, forKey: profileUrl as NSString)
                DispatchQueue.main.async {
                    self.profileImage = PostImage(url: profileUrl, uiImage: uiImage)
                }
            }
        }
    }

    // MARK: - 서버와 API 연동

    func fetchAllPosts() {
        print("[Debug] 모든 게시물 불러오기")
        print("\(#fileID) \(#function)")
        postService.fetchAllPosts(page: page) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.postImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(postId: post.id, postImages: post.images)
                }

                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.totalPages = pageInfo.totalPages
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetPosts(targetId: String) {
        print("[Debug] 특정 사용자 게시물 불러오기 사용자 ID: \(targetId)")
        print("\(#fileID) \(#function)")
        postService.fetchTargetPosts(targetId: targetId, page: page) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.postImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(postId: post.id, postImages: post.images)
                }

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
        postImageList = [:]
    }
}
