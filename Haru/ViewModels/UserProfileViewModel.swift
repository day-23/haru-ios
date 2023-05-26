//
//  UserProfileViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/08.
//

import Foundation
import SwiftUI

final class UserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var profileImage: PostImage?
    var userId: String
    var isMe: Bool {
        user.id == Global.shared.user?.id
    }

    @Published var friendList: [User] = []
    @Published var requestFriendList: [User] = [] // 사용자한테 친구 신청한 사람 (아직 수락하진 않은 상태)

    private let profileService: ProfileService = .init()
    private let friendService: FriendService = .init()

    init(userId: String) {
        self.user = User(
            id: userId,
            name: "",
            introduction: "",
            postCount: 0,
            friendCount: 0,
            friendStatus: 0,
            isPublicAccount: false
        )
        self.userId = userId
    }

    // MARK: - 이미지 캐싱

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

    // MARK: - 사용자 프로필을 위한 함수

    func fetchUserProfile() {
        profileService.fetchUserProfile(userId: userId) { result in
            switch result {
            case .success(let success):
                // 이미지 캐시
                if let profileUrl = success.profileImage {
                    self.fetchProfileImage(profileUrl: profileUrl)
                }

                self.userId = success.id
                self.user = success
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func updateUserProfile(
        name: String,
        introduction: String,
        profileImage: UIImage?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        if let profileImage {
            profileService.updateUserProfileWithImage(userId: userId, name: name, introduction: introduction, profileImage: profileImage) { result in
                switch result {
                case .success(let success):
                    // 이미지 캐시
                    if let profileUrl = success.profileImage {
                        self.fetchProfileImage(profileUrl: profileUrl)
                    }

                    self.user = success
                    // FIXME: Global 변경 되면 수정해주기
                    Global.shared.user?.user = success
                    completion(.success(true))
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                    completion(.failure(failure))
                }
            }
        } else {
            profileService.updateUserProfileWithoutImage(userId: userId, name: name, introduction: introduction) { result in
                switch result {
                case .success(let success):
                    self.user = success
                    // FIXME: Global 변경 되면 수정해주기
                    Global.shared.user?.user = success
                    completion(.success(true))
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                    completion(.failure(failure))
                }
            }
        }
    }

    // MARK: - 친구를 위한 함수

//    func fetchFollower(currentPage: Int) {
//        followService.fetchFollower(userId: user.id, page: currentPage) { result in
//            switch result {
//            case .success(let success):
//                self.followerList = success.0
//            case .failure(let failure):
//                print("[Debug] \(failure) \(#fileID) \(#function)")
//            }
//        }
//    }
//
//    func fetchFollowing(currentPage: Int) {
//        followService.fetchFollowing(userId: user.id, page: currentPage) { result in
//            switch result {
//            case .success(let success):
//                self.followingList = success.0
//            case .failure(let failure):
//                print("[Debug] \(failure) \(#fileID) \(#function)")
//            }
//        }
//    }

    /**
     * 나의 계정에서 userProfileVM의 user에게 팔로우를 신청
     */
//    func addFollowing(followId: String, completion: @escaping () -> Void) {
//        followService.addFollowing(followId: followId) { result in
//            switch result {
//            case .success:
//                self.user.isFollowing = true
//                if self.isMe {
//                    self.user.followingCount += 1
//                } else {
//                    self.user.followerCount += 1
//                }
//                completion()
//            case .failure(let failure):
//                print("[Debug] \(failure) \(#fileID) \(#function)")
//            }
//        }
//    }
//

    // TODO: 페이지네이션 적용하기
    func fetchFriend(userId: String, page: Int) {
        friendService.fetchFriend(userId: userId, page: page) { result in
            switch result {
            case .success(let success):
                self.friendList = success.0
            // TODO: 친구 프로필 이미지 캐싱하기
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // TODO: 페이지네이션 적용하기
    func fetchRequestFriend(userId: String, page: Int) {
        friendService.fetchRequestFriend(userId: userId, page: page) { result in
            switch result {
            case .success(let success):
                self.requestFriendList = success.0
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func requestFriend(
        followId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.requestFriend(followId: followId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func acceptRequestFriend(
        requestId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.acceptRequestFriend(requestId: requestId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func cancelRequestFriend(
        acceptorId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.cancelRequestFriend(acceptorId: acceptorId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func deleteFreined(followingId: String, completion: @escaping () -> Void) {
        friendService.deleteFriend(followingId: followingId) { result in
            switch result {
            case .success:
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    enum ProfileError: Error {
        case invalidUser
    }
}
