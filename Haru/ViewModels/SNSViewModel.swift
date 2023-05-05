//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation

class SNSViewModel: ObservableObject {
    @Published var mainPostList: [Post] = []
    
    @Published var myProfileURL: URL?
    
    @Published var myFeedList: [Feed] = [
        Feed(imageURL: URL(string: "https://blog.kakaocdn.net/dn/3x7MT/btqGY57LsGF/Ec2NJDHHv7Oo7rk08JPXD1/img.png")!, isLike: true),
        Feed(imageURL: URL(string: "https://blog.kakaocdn.net/dn/3x7MT/btqGY57LsGF/Ec2NJDHHv7Oo7rk08JPXD1/img.png")!, isLike: true)
    ]
    
    private let profileService: ProfileService = .init()
    private let postService: PostService = .init()
    
    func fetchProfileImg(userId: String = Global.shared.user?.id ?? "unknown") {
        profileService.fetchProfileImage(userId: userId) { result in
            switch result {
            case .success(let success):
                if let urlString = success.first?.url {
                    self.myProfileURL = URL(string: urlString)
                } else {
                    self.myProfileURL = URL(string: "https://cdn.ppomppu.co.kr/zboard/data3/2022/0509/m_20220509173224_d9N4ZGtBVR.jpeg")
                }
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
    
    func fetchAllPosts(currentPage: Int) {
        postService.fetchAllPosts(page: currentPage) { result in
            switch result {
            case .success(let success):
                self.mainPostList = success.0
                let pageInfo = success.1
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
