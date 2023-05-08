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
            postCount: 100,
            followerCount: 100,
            followingCount: 100,
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

    func updateUserProfile(name: String, introduction: String, profileImage: UIImage?) {
        profileService.updateUserProfile(userId: userId, name: name, introduction: introduction, profileImage: profileImage) { result in
            switch result {
            case .success(let success):
                print("Complete!!!")
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    enum ProfileError: Error {
        case invalidUser
    }
}
