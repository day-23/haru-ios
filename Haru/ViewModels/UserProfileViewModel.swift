//
//  UserProfileViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/08.
//

import Foundation
import SwiftUI

enum UserUpdate {
    case accept // 친구 수락
    case request // 친구 요청
    case refuse // 친구 삭제
    case cancel // 친구 취소
    case delete // 친구 삭제
    case block // 친구 차단
}

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

    @Published var friendCount: Int = -1
    @Published var reqFriendCount: Int = -1

    private let profileService: ProfileService = .init()
    private let friendService: FriendService = .init()
    private let searchService: SearchService = .init()

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
        clear()
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
        initLoad()
    }

    func reflectFriendList(targetIndex: Int, isFriendList: Bool, action: UserUpdate) {
        switch action {
        case .accept:
            if isFriendList {
                friendList[targetIndex].friendStatus = 2
            } else {
                requestFriendList[targetIndex].disabled = true
                requestFriendList[targetIndex].friendStatus = 2
            }
        case .request:
            if isFriendList {
                friendList[targetIndex].friendStatus = 1
            } else {
                requestFriendList[targetIndex].friendStatus = 1
                print("[Debug] 들어올 수 없는 플로우 입니다. \(#file) \(#function)")
            }
        case .refuse:
            if isFriendList {
                friendList[targetIndex].friendStatus = 0
            } else {
                requestFriendList[targetIndex].disabled = true
                requestFriendList[targetIndex].friendStatus = 0
            }
        case .cancel:
            if isFriendList {
                friendList[targetIndex].friendStatus = 0
            } else {
                requestFriendList[targetIndex].friendStatus = 0
                print("[Debug] 들어올 수 없는 플로우 입니다. \(#file) \(#function)")
            }
        case .delete:
            if isFriendList {
                friendList[targetIndex].friendStatus = 0
                if isMe {
                    friendList[targetIndex].disabled = true
                }
            } else {
                requestFriendList[targetIndex].friendStatus = 0
                requestFriendList[targetIndex].disabled = true
                print("[Debug] 들어올 수 없는 플로우 입니다. \(#file) \(#function)")
            }
        case .block:
            if isFriendList {
                friendList[targetIndex].friendStatus = 0
                if isMe {
                    friendList[targetIndex].disabled = true
                }
            } else {
                requestFriendList[targetIndex].friendStatus = 0
                requestFriendList[targetIndex].disabled = true
                print("[Debug] 들어올 수 없는 플로우 입니다. \(#file) \(#function)")
            }
        }
    }

    func clear() {
        friendList.removeAll()
        friProfileImageList.removeAll()

        requestFriendList.removeAll()
        reqFriProImageList.removeAll()
    }

    // MARK: - 이미지 캐싱

    func fetchProfileImage(
        profileUrl: String,
        completion: @escaping (PostImage) -> Void
    ) {
        DispatchQueue.global().async {
            if let uiImage = ImageCache.shared.object(forKey: profileUrl as NSString) {
                completion(PostImage(url: profileUrl, uiImage: uiImage, mimeType: "image/png"))
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
                completion(PostImage(url: profileUrl, uiImage: uiImage, mimeType: "image/png"))
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

                var result = success.0
                for friend in self.friendList {
                    result = result.filter {
                        $0.id != friend.id
                    }
                }

                self.friendList.append(contentsOf: result)
                let pageInfo = success.1
                if self.friendListTotalPage == -1 {
                    self.friendListTotalPage = pageInfo.totalPages
                }
                self.friendCount = pageInfo.totalItems
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

                var result = success.0
                for friend in self.friendList {
                    result = result.filter {
                        $0.id != friend.id
                    }
                }

                self.requestFriendList.append(contentsOf: result)
                let pageInfo = success.1
                if self.reqFriListTotalPage == -1 {
                    self.reqFriListTotalPage = pageInfo.totalPages
                }
                self.reqFriendCount = pageInfo.totalItems
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
        isRefuse: Bool = true,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.cancelRequestFriend(
            acceptorId: acceptorId,
            isRefuse: isRefuse
        ) { result in
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

    func searchFriend(
        name: String,
        completion: @escaping () -> Void
    ) {
        switch option {
        case .friendList:
            searchService.searchFriendWithName(name: name) { result in
                switch result {
                case .success(let success):
                    success.forEach { user in
                        self.friProfileImageList[user.id] = nil
                        if let profileUrl = user.profileImageUrl {
                            self.fetchProfileImage(profileUrl: profileUrl) { profileImage in
                                DispatchQueue.main.async {
                                    self.friProfileImageList[user.id] = profileImage
                                }
                            }
                        }
                    }
                    self.friendList = success
                    completion()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#file) \(#function)")
                    completion()
                }
            }
        case .requestFriendList:
            searchService.searchReqFriendWithName(name: name) { result in
                switch result {
                case .success(let success):
                    success.forEach { user in
                        self.reqFriProImageList[user.id] = nil
                        if let profileUrl = user.profileImageUrl {
                            self.fetchProfileImage(profileUrl: profileUrl) { profileImage in
                                DispatchQueue.main.async {
                                    self.reqFriProImageList[user.id] = profileImage
                                }
                            }
                        }
                    }
                    self.requestFriendList = success
                    completion()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#file) \(#function)")
                    completion()
                }
            }
        }
    }

    enum ProfileError: Error {
        case invalidUser
    }
}
