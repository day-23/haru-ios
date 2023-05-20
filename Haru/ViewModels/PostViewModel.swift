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

    var option: PostOption

    var page: Int { // 불러올 페이지
        switch option {
        case .main:
            return Int(ceil(Double(postList.count) / 5.0)) + 1
        case .target_feed:
            return Int(ceil(Double(postList.count) / 5.0)) + 1
        case .target_media:
            guard let mediaList = mediaList[Global.shared.hashTagAll.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        case .target_media_hashtag:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        case .media:
            guard let mediaList = mediaList[Global.shared.hashTagAll.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        }
    }

    var feedTotalPage: Int = -1
    var mediaTotalPage: [HashTag.ID: Int] = [:]

    var lastCreatedAt: Date? {
        switch option {
        case .main:
            return postList.first?.createdAt
        case .target_feed:
            return postList.first?.createdAt
        case .target_media:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        case .target_media_hashtag:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        case .media:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        }
    }

    var targetId: String?

    private let postService: PostService

    init(targetId: String? = nil, option: PostOption) {
        self.targetId = targetId
        self.option = option
        postService = .init()
    }

    func loadMorePosts() {
        switch option {
        case .main:
            if feedTotalPage != -1 {
                if page > feedTotalPage {
                    print("[Error] 더 이상 불러올 게시물이 없습니다")
                    print("\(#function) \(#fileID)")
                    return
                }
            }

            fetchFreindsPosts(page: page, lastCreatedAt: lastCreatedAt)

        case .target_feed:
            if feedTotalPage != -1 {
                if page > feedTotalPage {
                    print("[Error] 더 이상 불러올 게시물이 없습니다")
                    print("\(#function) \(#fileID)")
                    return
                }
            }

            guard let targetId else {
                print("[Debug] targetId가 잘못되었습니다.")
                print("\(#function) \(#fileID)")
                return
            }

            fetchTargetPosts(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt)

        case .target_media:
            if let mediaTotalPage = mediaTotalPage[selectedHashTag.id] {
                if page > mediaTotalPage {
                    print("[Error] 더 이상 불러올 게시물이 없습니다")
                    print("\(#function) \(#fileID)")
                    return
                }
            }

            guard let targetId else { return }
            fetchTargetMediaAll(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt)

        case .target_media_hashtag:
            if let mediaTotalPage = mediaTotalPage[selectedHashTag.id] {
                if page > mediaTotalPage {
                    print("[Error] 더 이상 불러올 게시물이 없습니다")
                    print("\(#function) \(#fileID)")
                    return
                }
            }

            guard let targetId else { return }
            fetchTargetMediaHashTag(targetId: targetId, hashTagId: selectedHashTag.id, page: page, lastCreatedAt: lastCreatedAt)

        case .media:
            print("둘러보기")
        }
    }

    func refreshPosts() {
        clear(option: option)
    }

    // MARK: - UIImage로 변환 + 이미지 캐싱

    func fetchPostImage(postId: String, postImageUrlList: [String], isMedia: Bool = false) {
        DispatchQueue.global().async {
            postImageUrlList.enumerated().forEach { idx, urlString in
                if let uiImage = ImageCache.shared.object(forKey: urlString as NSString) {
                    DispatchQueue.main.async {
                        if isMedia {
                            self.mediaImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage)
                        } else {
                            self.postImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage)
                        }
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

    func fetchFreindsPosts(
        page: Int,
        lastCreatedAt: Date?)
    {
        print("[Debug] 모든 게시물 불러오기")
        print("\(#fileID) \(#function)")
        postService.fetchFreindPosts(page: page, lastCreatedAt: lastCreatedAt) { result in
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
                self.feedTotalPage = self.feedTotalPage == -1 ? pageInfo.totalPages : self.feedTotalPage

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetPosts(
        targetId: String,
        page: Int,
        lastCreatedAt: Date?)
    {
        print("[Debug] 특정 사용자 게시물 불러오기 사용자 ID: \(targetId)")
        print("\(#fileID) \(#function)")
        postService.fetchTargetPosts(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt) { result in
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
                self.feedTotalPage = self.feedTotalPage == -1 ? pageInfo.totalPages : self.feedTotalPage

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // TODO: 인기 미디어 전체보기 해야함
    func fetchAllMedia(targetId: String) {}

    func fetchTargetMediaAll(
        targetId: String,
        page: Int,
        lastCreatedAt: Date?)
    {
        postService.fetchTargetMediaAll(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt) { result in
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
                if self.mediaTotalPage[Global.shared.hashTagAll.id] == nil {
                    self.mediaTotalPage[Global.shared.hashTagAll.id] = pageInfo.totalPages
                }

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchTargetMediaHashTag(
        targetId: String,
        hashTagId: String,
        page: Int,
        lastCreatedAt: Date?)
    {
        postService.fetchTargetMediaHashTag(targetId: targetId, hashTagId: hashTagId, page: page, lastCreatedAt: lastCreatedAt) { result in
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

                self.mediaList[hashTagId] = (self.mediaList[hashTagId] ?? []) + success.0
                let pageInfo = success.1
                if self.mediaTotalPage[hashTagId] == nil {
                    self.mediaTotalPage[hashTagId] = pageInfo.totalPages
                }

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // MARK: - 게시물 이외

    func fetchTargetHashTags() {
        guard let targetId else { return }
        postService.fetchTargetHashTags(targetId: targetId) { result in
            switch result {
            case .success(let success):
                self.hashTags = [Global.shared.hashTagAll] + success
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
            postList = []
            postImageList = [:]

        case .target_feed:
            postList = []
            postImageList = [:]

        case .target_media:
            mediaList = [:]
            mediaImageList = [:]

        case .target_media_hashtag:
            mediaList = [:]
            mediaImageList = [:]

        case .media:
            mediaList = [:]
            mediaImageList = [:]
        }
    }
}
