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
    var userId: String

    @Published var followerList: [User] = []
    @Published var followingList: [User] = []

    private let profileService: ProfileService = .init()
    private let followService: FollowService = .init()

    init(userId: String) {
        self.user = User(
            id: userId,
            name: "",
            introduction: "",
            postCount: 0,
            followerCount: 0,
            followingCount: 0,
            isFollowing: false
        )
        self.userId = userId
        fetchUserProfile()
    }

    // MARK: - 사용자 프로필을 위한 함수

    func fetchUserProfile() {
        profileService.fetchUserProfile(userId: userId) { result in
            switch result {
            case .success(let success):
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
//        let profile = Request.Profile(name: name, introduction: introduction)

        if profileImage != nil {
        } else {
            profileService.updateUserProfileWithoutImage(userId: userId, name: name, introduction: introduction) { result in
                switch result {
                case .success(let success):
                    self.user = success
                    // FIXME: Global 변경 되면 수정해주기
                    Global.shared.user = success
                    completion(.success(true))
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                    completion(.failure(failure))
                }
            }
        }
    }

    // MARK: - 팔로우를 위한 함수

    func fetchFollower(currentPage: Int) {
        followService.fetchFollower(userId: user.id, page: currentPage) { result in
            switch result {
            case .success(let success):
                self.followerList = success.0
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func fetchFollowing(currentPage: Int) {
        followService.fetchFollowing(userId: user.id, page: currentPage) { result in
            switch result {
            case .success(let success):
                self.followingList = success.0
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    /**
     * 나의 계정에서 userProfileVM의 user에게 팔로우를 신청
     */
    func addFollowing(followId: String) {
        followService.addFollowing(followId: followId) { result in
            switch result {
            case .success:
                self.user.isFollowing = true
                self.user.followerCount += 1
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func cancelFollowing(followingId: String) {
        followService.cancelFollowing(followingId: followingId) { result in
            switch result {
            case .success:
                self.user.isFollowing = false
                self.user.followerCount -= 1
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    enum ProfileError: Error {
        case invalidUser
    }
}
