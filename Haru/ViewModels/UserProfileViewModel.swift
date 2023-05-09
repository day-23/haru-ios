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

    enum ProfileError: Error {
        case invalidUser
    }
}
