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

    /**
     * 나의 계정에서 userProfileVM의 user에게 팔로우를 신청하는 수수
     */
    func addFollowing() {
        followService.addFollowing(followId: user.id) { result in
            switch result {
            case .success:
                self.user.isFollowing = true
                self.user.followerCount += 1
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func cancelFollowing() {
        followService.cancelFollowing(followingId: user.id) { result in
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
