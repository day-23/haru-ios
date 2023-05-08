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
    let defaultURL: String = "https://harus3.s3.ap-northeast-2.amazonaws.com/profile/1683173179099_KakaoTalk_Photo_2023-04-28-14-51-32.png"

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
