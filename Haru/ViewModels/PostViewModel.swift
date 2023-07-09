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

    // TODO: 프로필 이미지들로 받기
    @Published var profileImageList: [Post.ID: PostImage?] = [:]

    var option: PostOption

    var page: Int { // 불러올 페이지
        switch option {
        case .main:
            return Int(ceil(Double(postList.count) / 5.0)) + 1
        case .targetFeed:
            return Int(ceil(Double(postList.count) / 5.0)) + 1
        case .targetMediaAll:
            guard let mediaList = mediaList[Global.shared.hashTagAll.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        case .targetMediaHashtag:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        case .mediaAll:
            guard let mediaList = mediaList[Global.shared.hashTagAll.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        case .mediaHashtag:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return 1
            }
            return Int(ceil(Double(mediaList.count) / 12.0)) + 1
        }
    }

    var feedTotalPage: Int = -1
    var mediaTotalPage: [HashTag.ID: Int] = [:]
    var mediaTotalItems: [HashTag.ID: Int] = [:]
    var isEnd: Bool = false

    var lastCreatedAt: Date? {
        switch option {
        case .main:
            return postList.first?.createdAt
        case .targetFeed:
            return postList.first?.createdAt
        case .targetMediaAll:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        case .targetMediaHashtag:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        case .mediaAll:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        case .mediaHashtag:
            guard let mediaList = mediaList[selectedHashTag.id] else {
                return nil
            }
            return mediaList.first?.createdAt
        }
    }

    var targetId: String? // targetId가 nil이면 둘러보기 / 아니면 사용자 피드

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
                    return
                }
            }

            fetchFreindsPosts(page: page, lastCreatedAt: lastCreatedAt)

        case .targetFeed:
            if feedTotalPage != -1 {
                if page > feedTotalPage {
                    return
                }
            }

            guard let targetId else {
                print("[Debug] targetId가 nil 입니다.")
                print("\(#function) \(#fileID)")
                return
            }

            fetchTargetPosts(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt)

        case .targetMediaAll:
            if let mediaTotalPage = mediaTotalPage[selectedHashTag.id] {
                if page > mediaTotalPage {
                    return
                }
            }

            guard let targetId else {
                print("[Debug] targetId가 nil 입니다.")
                print("\(#function) \(#fileID)")
                return
            }

            fetchTargetMediaAll(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt)

        case .targetMediaHashtag:
            if let mediaTotalPage = mediaTotalPage[selectedHashTag.id] {
                if page > mediaTotalPage {
                    return
                }
            }

            guard let targetId else {
                print("[Debug] targetId가 nil 입니다.")
                print("\(#function) \(#fileID)")
                return
            }

            fetchTargetMediaHashTag(targetId: targetId, hashTagId: selectedHashTag.id, page: page, lastCreatedAt: lastCreatedAt)

        case .mediaAll:
            if let mediaTotalPage = mediaTotalPage[selectedHashTag.id] {
                if page > mediaTotalPage {
                    return
                }
            }

            fetchMediaAll(page: page, lastCreatedAt: lastCreatedAt)

        case .mediaHashtag:
            if let mediaTotalPage = mediaTotalPage[selectedHashTag.id] {
                if page > mediaTotalPage {
                    return
                }
            }

            fetchMediaHashTag(hashTagId: selectedHashTag.id, page: page, lastCreatedAt: lastCreatedAt)
        }
    }

    func refreshPosts() {
        clear()
        loadMorePosts()
    }

    // 게시물 생성 시 게시물 리스트 다시 다 불러오기
    func reloadPosts() {
        postList = []
        postImageList = [:]
        mediaList = [:]
        mediaImageList = [:]

        fetchFreindsPosts(page: 1, lastCreatedAt: nil)
        fetchMediaAll(page: 1, lastCreatedAt: nil)
        if selectedHashTag.id != Global.shared.hashTagAll.id {
            fetchMediaHashTag(hashTagId: selectedHashTag.id, page: 1, lastCreatedAt: nil)
        }
    }

    // MARK: - UIImage로 변환 + 이미지 캐싱

    func fetchPostImage(
        postId: String,
        postImageUrlList: [String],
        mimeTypeList: [String],
        isMedia: Bool = false)
    {
        DispatchQueue.global().async {
            postImageUrlList.enumerated().forEach { idx, urlString in
                if let cacheData = ImageCache.shared.object(forKey: urlString as NSString) {
                    DispatchQueue.main.async {
                        if isMedia {
                            self.mediaImageList[postId]?[idx] = PostImage(url: urlString, uiImage: cacheData, mimeType: mimeTypeList[idx])
                        } else {
                            self.postImageList[postId]?[idx] = PostImage(url: urlString, uiImage: cacheData, mimeType: mimeTypeList[idx])
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
                            self.mediaImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage, mimeType: mimeTypeList[idx], data: data)
                        } else {
                            self.postImageList[postId]?[idx] = PostImage(url: urlString, uiImage: uiImage, mimeType: mimeTypeList[idx], data: data)
                        }
                    }
                }
            }
        }
    }

    func fetchProfileImage(postId: String, profileUrl: String) {
        DispatchQueue.global().async {
            if let uiImage = ImageCache.shared.object(forKey: profileUrl as NSString) {
                DispatchQueue.main.async {
                    self.profileImageList[postId] = PostImage(url: profileUrl, uiImage: uiImage, mimeType: "image/png")
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
                    self.profileImageList[postId] = PostImage(url: profileUrl, uiImage: uiImage, mimeType: "image/png")
                }
            }
        }
    }

    // MARK: - 서버와 API 연동

    func fetchFreindsPosts(
        page: Int,
        lastCreatedAt: Date?)
    {
        postService.fetchFreindPosts(page: page, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(postId: post.id, profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.postImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map { image in
                            image.url
                        },
                        mimeTypeList: post.images.map { image in
                            image.mimeType
                        })
                }

                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.feedTotalPage = min(pageInfo.totalPages, 20)

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
        postService.fetchTargetPosts(targetId: targetId, page: page, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                // 이미지 캐싱
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(postId: post.id, profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.postImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map { image in
                            image.url
                        },
                        mimeTypeList: post.images.map { image in
                            image.mimeType
                        })
                }

                self.postList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.feedTotalPage = min(pageInfo.totalPages, 20)

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

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
                        self.fetchProfileImage(postId: post.id, profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.mediaImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map(\.url),
                        mimeTypeList: post.images.map(\.mimeType),
                        isMedia: true)
                }

                self.mediaList[self.hashTags[0].id] = (self.mediaList[self.hashTags[0].id] ?? []) + success.0
                let pageInfo = success.1
                self.mediaTotalPage[Global.shared.hashTagAll.id] = min(pageInfo.totalPages, 8)
                self.mediaTotalItems[Global.shared.hashTagAll.id] = min(pageInfo.totalItems, 12 * 8)

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
                        self.fetchProfileImage(postId: post.id, profileUrl: profileUrl)
                    }
                    // 게시물 이미지 캐싱 (하나의 게시물에 여러개의 이미지)
                    self.mediaImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map(\.url),
                        mimeTypeList: post.images.map(\.mimeType),
                        isMedia: true)
                }

                self.mediaList[hashTagId] = (self.mediaList[hashTagId] ?? []) + success.0
                let pageInfo = success.1
                self.mediaTotalPage[hashTagId] = min(pageInfo.totalPages, 8)
                self.mediaTotalItems[Global.shared.hashTagAll.id] = min(pageInfo.totalItems, 12 * 8)

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // 둘러보기 > 전체보기
    func fetchMediaAll(
        page: Int,
        lastCreatedAt: Date?)
    {
        postService.fetchAllMedia(page: page, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(postId: post.id, profileUrl: profileUrl)
                    }

                    self.mediaImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map(\.url),
                        mimeTypeList: post.images.map(\.mimeType),
                        isMedia: true)
                }

                self.mediaList[self.hashTags[0].id] = (self.mediaList[self.hashTags[0].id] ?? []) + success.0
                let pageInfo = success.1
                self.mediaTotalPage[Global.shared.hashTagAll.id] = min(pageInfo.totalPages, 8)
                self.mediaTotalItems[Global.shared.hashTagAll.id] = min(pageInfo.totalItems, 12 * 8)

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // 둘러보기 > 해시태그
    func fetchMediaHashTag(
        hashTagId: String,
        page: Int,
        lastCreatedAt: Date?)
    {
        postService.fetchMediaHashTag(hashTagId: hashTagId, page: page, lastCreatedAt: lastCreatedAt) { result in
            switch result {
            case .success(let success):
                success.0.forEach { post in
                    // 프로필 이미지 캐싱
                    if let profileUrl = post.user.profileImage {
                        self.fetchProfileImage(postId: post.id, profileUrl: profileUrl)
                    }

                    self.mediaImageList[post.id] = Array(repeating: nil, count: post.images.count)
                    self.fetchPostImage(
                        postId: post.id,
                        postImageUrlList: post.images.map(\.url),
                        mimeTypeList: post.images.map(\.mimeType),
                        isMedia: true)
                }

                self.mediaList[hashTagId] = (self.mediaList[hashTagId] ?? []) + success.0
                let pageInfo = success.1
                self.mediaTotalPage[hashTagId] = min(pageInfo.totalPages, 8)
                self.mediaTotalItems[Global.shared.hashTagAll.id] = min(pageInfo.totalItems, 12 * 8)

            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // MARK: - 게시물 수정, 삭제, 숨기기

    func deletePost(postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        postService.deletePost(postId: postId) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func hidePost(postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        postService.hidePost(postId: postId) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func reportPost(postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        postService.reportPost(postId: postId) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    // MARK: - 게시물 이외

    func fetchPopularHashTags() {
        postService.fetchPopularHashTags { result in
            switch result {
            case .success(let success):
                self.hashTags = [Global.shared.hashTagAll] + success
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
                self.hashTags = [Global.shared.hashTagAll] + success
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func likeThisPost(
        targetPostId: String,
        completion: @escaping () -> Void)
    {
        postService.likeThisPost(targetPostId: targetPostId) { result in
            switch result {
            case .success:
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func disablePost(targetPost: Post?) {
        guard let targetPost else { return }

        // 친구피드 쪽에서 안보이게
        if let index = (postList.firstIndex { post in
            post.id == targetPost.id
        }) {
            postList[index].disabled = true
        }

        // 전체보기 쪽에서 안보이게
        if let index = mediaList[Global.shared.hashTagAll.id]?.firstIndex(where: { post in
            post.id == targetPost.id
        }) {
            mediaList[Global.shared.hashTagAll.id]?[index].disabled = true
        }

        // 해시태그 쪽에서 안보이게
        targetPost.hashTags.forEach { content in
            guard let hashTag = hashTags.first(where: { $0.content == content }) else { return }
            guard let index = (mediaList[hashTag.id]?.firstIndex { post in
                post.id == targetPost.id
            }) else { return }

            self.mediaList[hashTag.id]?[index].disabled = true
        }
    }

    func clear() {
        switch option {
        case .main:
            postList = []
            postImageList = [:]
        case .targetFeed:
            postList = []
            postImageList = [:]
        case .targetMediaAll:
            mediaList = [:]
            mediaImageList = [:]
        case .targetMediaHashtag:
            mediaList = [:]
            mediaImageList = [:]
        case .mediaAll:
            mediaList = [:]
            mediaImageList = [:]
        case .mediaHashtag:
            mediaList = [:]
            mediaImageList = [:]
        }
    }
}
