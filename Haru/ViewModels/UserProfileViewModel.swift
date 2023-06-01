//
//  UserProfileViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/08.
//

import Foundation
import SwiftUI

final class UserProfileViewModel: ObservableObject {
    @Published var user: User // 현재 보고 있는 사용자
    @Published var profileImage: PostImage? // 현재 보고 있는 사용자의 프로필 이미지
    var userId: String // 현재 보고 있는 사용자의 id
    var isMe: Bool {
        user.id == Global.shared.user?.id
    }

    var isPublic: Bool {
        user.friendStatus == 2 || isMe || user.isPublicAccount
    }

    @Published var friendList: [FriendUser] = [] // 현재 보고 있는 사용자의 친구 목록
    @Published var requestFriendList: [FriendUser] = [] // 현재 보고 있는 사용자의 친구 신청 목록

    @Published var friProfileImageList: [FriendUser.ID: PostImage?] = [:] // key값인 User.ID는 firendList의 User와 맵핑
    @Published var reqFriProImageList: [FriendUser.ID: PostImage?] = [:] // key값인 User.ID는 reqfriList의 User와 맵핑

    var friendCount: Int = 0

    var reqFriendCount: Int = 0 // 현재 보고 있는 사용자의 친구 요청 수

    private let profileService: ProfileService = .init()
    private let friendService: FriendService = .init()

    var option: FriendOption = .friendList

    var page: Int {
        switch option {
        case .friendList:
            return Int(ceil(Double(friendList.count) / 20.0)) + 1
        case .requestFriendList:
            return Int(ceil(Double(requestFriendList.count) / 20.0)) + 1
        }
    }

    var friendListTotalPage: Int = -1
    var reqFriListTotalPage: Int = -1

    init(userId: String) {
        user = User(
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

    // MARK: - 페이지네이션

    func initLoad() {
        fetchFriend(userId: userId, page: page)
        fetchRequestFriend(userId: userId, page: page)
    }

    func loadMoreFriendList() {
        switch option {
        case .friendList:
            if friendListTotalPage != -1 {
                if page > friendListTotalPage {
                    print("[Error] 더 이상 불러올 친구 목록이 없습니다")
                    print("\(#function) \(#fileID)")
                    return
                }
            }

            fetchFriend(userId: userId, page: page)

        case .requestFriendList:
            if reqFriListTotalPage != -1 {
                if page > reqFriListTotalPage {
                    print("[Error] 더 이상 불러올 친구신청 목록이 없습니다")
                    print("\(#function) \(#fileID)")
                    return
                }
            }

            fetchRequestFriend(userId: userId, page: page)
        }
    }

    func refreshFriendList() {
        clear(option: option)
        loadMoreFriendList()
    }

    func clear(option: FriendOption) {
        switch option {
        case .friendList:
            friendList.removeAll()
            friProfileImageList.removeAll()
        case .requestFriendList:
            requestFriendList.removeAll()
            reqFriProImageList.removeAll()
        }
    }

    // MARK: - 이미지 캐싱

    func fetchProfileImage(
        profileUrl: String,
        completion: @escaping (PostImage) -> Void
    ) {
        DispatchQueue.global().async {
            if let uiImage = ImageCache.shared.object(forKey: profileUrl as NSString) {
                completion(PostImage(url: profileUrl, uiImage: uiImage))
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
                completion(PostImage(url: profileUrl, uiImage: uiImage))
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
                    self.fetchProfileImage(profileUrl: profileUrl) { profileImage in
                        DispatchQueue.main.async {
                            self.profileImage = profileImage
                        }
                    }
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
                        self.fetchProfileImage(profileUrl: profileUrl) { profileImage in
                            DispatchQueue.main.async {
                                self.profileImage = profileImage
                            }
                        }
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

    // userId: 해당 사용자의 친구목록을 불러옴
    func fetchFriend(userId: String, page: Int) {
        friendService.fetchFriend(userId: userId, page: page) { result in
            switch result {
            case .success(let success):
                success.0.forEach { user in
                    self.friProfileImageList[user.id] = nil
                    if let profileUrl = user.profileImageUrl {
                        self.fetchProfileImage(profileUrl: profileUrl) { profileImage in
                            DispatchQueue.main.async {
                                self.friProfileImageList[user.id] = profileImage
                            }
                        }
                    }
                }

                self.friendList.append(contentsOf: success.0)
                let pageInfo = success.1
                self.friendCount = pageInfo.totalItems
                if self.friendListTotalPage == -1 {
                    self.friendListTotalPage = pageInfo.totalPages
                }

            // TODO: 친구 프로필 이미지 캐싱하기
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // userId: 해당 사용자의 친구신청 목록을 불러옴
    func fetchRequestFriend(userId: String, page: Int) {
        friendService.fetchRequestFriend(userId: userId, page: page) { result in
            switch result {
            case .success(let success):
                success.0.forEach { user in
                    self.reqFriProImageList[user.id] = nil
                    if let profileUrl = user.profileImageUrl {
                        self.fetchProfileImage(profileUrl: profileUrl) { profileImage in
                            DispatchQueue.main.async {
                                self.reqFriProImageList[user.id] = profileImage
                            }
                        }
                    }
                }

                self.requestFriendList = success.0
                let pageInfo = success.1
                self.reqFriendCount = pageInfo.totalItems
                if self.reqFriListTotalPage == -1 {
                    self.reqFriListTotalPage = pageInfo.totalPages
                }
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    // acceptorId: 친구신청을 하고 싶은 사용자의 아이디
    func requestFriend(
        acceptorId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.requestFriend(acceptorId: acceptorId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    // requesterId: 친구신청을 보낸 사용자의 아이디
    func acceptRequestFriend(
        requesterId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.acceptRequestFriend(requesterId: requesterId) { result in
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

    // friendId: 삭제할 친구의 id
    func deleteFriend(friendId: String, completion: @escaping () -> Void) {
        friendService.deleteFriend(friendId: friendId) { result in
            switch result {
            case .success:
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func blockedFriend(
        blockUserId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.blockFriend(blockUserId: blockUserId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    enum ProfileError: Error {
        case invalidUser
    }
}
