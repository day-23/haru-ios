//
//  UserProfileViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/08.
//

import Foundation
import SwiftUI

final class UserProfileViewModel: ObservableObject {
    @Published var imageUrl: URL?

    @Published var user: User?
    var userId: String

    private let profileService: ProfileService = .init()
    private static let defaultURL: String = "https://harus3.s3.ap-northeast-2.amazonaws.com/profile/1683173179099_KakaoTalk_Photo_2023-04-28-14-51-32.png"

    init(userId: String) {
        self.userId = userId
        fetchUserProfile()
    }

    func fetchUserProfile() {
        profileService.fetchUserProfile(userId: userId) { result in
            switch result {
            case .success(let success):
                self.user = success
                guard let url = URL(string: success.profileImage ?? Self.defaultURL) else {
                    print("[Error] \(success.profileImage ?? Self.defaultURL)를 url 형식으로 변환 불가능합니다. \(#function) \(#fileID)")
                    return
                }
                self.imageUrl = url
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func updateUserProfile() {}

    enum ProfileError: Error {
        case invalidUser
    }
}
