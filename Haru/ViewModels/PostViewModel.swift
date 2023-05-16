//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation
import SwiftUI

final class PostViewModel: ObservableObject {
    // MARK: 피드를 위한 필드

    @Published var postList: [Post] = [] // 게시물 > 피드
    @Published var postImageList: [Post.ID: [PostImage?]] = [:] // 게시물 > 피드 > 사진들

    // MARK: 미디어를 위한 필드

    @Published var mediaList: [HashTag.ID: [Post]] = [:] // 게시물 > 미디어
    @Published var mediaImageList: [Post.ID: [PostImage?]] = [:] // 게시물 > 미디어 > 사진들
    @Published var hashTags: [HashTag] = [Global.shared.hashTagAll]
    @Published var selectedHashTag: HashTag = Global.shared.hashTagAll

    // MARK: postVM 공용 필드

    @Published var profileImage: PostImage?
    @Published var feedFirstTimeAppear: Bool = true // 처음인지 아닌지 확인
    @Published var mediaFirstTimeAppear: Bool = true // 처음인지 아닌지 확인

    var lastCreatedAt: Date? {
        postList.first?.createdAt
    }

    var feedPage: Int = 1
    var feedTotalPages: Int = 0

    var mediaPage: Int = 1
    var mediaTotalPages: Int = 0

    var targetId: String?

    private let postService: PostService

    init(targetId: String? = nil) {
        self.targetId = targetId
        postService = .init()
    }

    func loadMorePosts(option: PostOption) {
        switch option {
        case .main:
            if !feedFirstTimeAppear {
                if (feedPage + 1) > feedTotalPages {
                    return
                }
                feedPage += 1
            }
            fetchFreindsPosts()
            feedFirstTimeAppear = false
        case .target_feed:
            if !feedFirstTimeAppear {
                if (feedPage + 1) > feedTotalPages {
                    return
                }
                feedPage += 1
            }
            guard let targetId else { return }
            fetchTargetPosts(targetId: targetId)
            feedFirstTimeAppear = false
        case .target_media:
            print("[Debug] \(targetId) 미디어 불러오기")
            print("\(#function) \(#fileID)")
            if !mediaFirstTimeAppear {
                if (mediaPage + 1) > mediaTotalPages {
                    return
                }
                mediaPage += 1
            }
            guard let targetId else { return }
            fetchTargetMediaAll(targetId: targetId)
            mediaFirstTimeAppear = false
        case .target_media_hashtag:
            print("헤시태그 불러오기")
        case .media:
            print("둘러보기")
        }
    }

    func refreshPosts(option: PostOption) {
        clear(option: option)
        loadMorePosts(option: option)
    }

    // MARK: - UIImage로 변환 + 이미지 캐싱

    func fetchPostImage(postId: String, postImageUrlList: [String], isMedia: Bool = false) {
        DispatchQueue.global().async {
            postImageUrlList.enumerated().forEach { idx, urlString in
                if let uiImage = ImageCache.shared.object(forKey: urlString as NSString) {
                    DispatchQueue.main.async {
                        self.postImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage)
                    }
                } else {
                    guard
                        let url = URL(string: urlString.encodeUrl()!),
                        let data = try? Data(contentsOf: url),
                        let uiImage = UIImage(data: data)
                    else {
                        print("[Error] \(urlString)이 잘못됨 \(#fileID) \(#function)")
                        return
                    }

                    ImageCache.shared.setObject(uiImage, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        if isMedia {
                            self.mediaImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage)
                        } else {
                            self.postImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage)
                        }
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

    func fetchFreindsPosts() {
        print("[Debug] 모든 게시물 불러오기")
        print("\(#fileID) \(#function)")
        postService.fetchFreindPosts(page: feedPage, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    if let templateUrl = post.templateUrl {
                        self.postImageList[post.id] = Array(repeating: nil, count: 1)
                        self.fetchPostImage(postId: post.id, postImageUrlList: [templateUrl])
                    } else {
                        self.postImageList[post.id] = Array(repeating: nil, count: post.images.count)
                        self.fetchPostImage(
                            postId: post.id,
                            postImageUrlList: post.images.map { image in
                                image.url
                            })
                    }
                }

                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.feedTotalPages = pageInfo.totalPages

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetPosts(targetId: String) {
        print("[Debug] 특정 사용자 게시물 불러오기 사용자 ID: \(targetId)")
        print("\(#fileID) \(#function)")
        postService.fetchTargetPosts(targetId: targetId, page: feedPage, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    if let templateUrl = post.templateUrl {
                        self.postImageList[post.id] = Array(repeating: nil, count: 1)
                        self.fetchPostImage(postId: post.id, postImageUrlList: [templateUrl])
                    } else {
                        self.postImageList[post.id] = Array(repeating: nil, count: post.images.count)
                        self.fetchPostImage(
                            postId: post.id,
                            postImageUrlList: post.images.map { image in
                                image.url
                            })
                    }
                }

                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.feedTotalPages = pageInfo.totalPages
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // TODO: 인기 미디어 전체보기 해야함
    func fetchAllMedia(targetId: String) {}

    func fetchTargetMediaAll(targetId: String) {
        postService.fetchTargetMediaAll(targetId: targetId, page: mediaPage, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.mediaImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map(\.url),
                        isMedia: true)
                }

                self.mediaList[self.hashTags[0].id] = (self.mediaList[self.hashTags[0].id] ?? []) + success.0
                let pageInfo = success.1
                self.mediaTotalPages = pageInfo.totalPages

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetHashTags() {
        guard let targetId else { return }
        postService.fetchTargetHashTags(targetId: targetId) { result in
            switch result {
            case .success(let success):
                self.hashTags.append(contentsOf: success)
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

    func clear(option: PostOption) {
        switch option {
        case .main:
            feedPage = 1
            postList = []
            postImageList = [:]
            feedFirstTimeAppear = true
        case .target_feed:
            feedPage = 1
            postList = []
            postImageList = [:]
            feedFirstTimeAppear = true
        case .target_media:
            mediaPage = 1
            mediaList = [:]
            mediaImageList = [:]
            mediaFirstTimeAppear = true
        case .target_media_hashtag:
            mediaPage = 1
            mediaList = [:]
            mediaImageList = [:]
            mediaFirstTimeAppear = true
        case .media:
            mediaPage = 1
            mediaList = [:]
            mediaImageList = [:]
            mediaFirstTimeAppear = true
        }
    }
}
