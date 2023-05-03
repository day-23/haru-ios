//
//  SNSViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation

class SNSViewModel: ObservableObject {
    @Published var feedList: [Feed] = [
        Feed(imageURL: URL(string: "https://img.seoul.co.kr/img/upload/2018/04/22/SSI_2018042215294102_O2.jpg")!, isLike: false),
        
        Feed(content: "아이콘-텍스트 간격 10 텍스트/아이콘-아래줄 간격 20, 14pt", imageURL: URL(string: "https://cdn.hankooki.com/news/photo/202301/46144_62027_1673489105.jpg")!, isLike: true),
        
        Feed(imageURL: URL(string: "https://cdn.mydaily.co.kr/FILES/202207/202207141745744091_1.jpg")!, isLike: false),
        
        Feed(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: true),
        
        Feed(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: true)
    ]
    
    @Published var myProfileURL: URL?
    
    @Published var myFeedList: [Feed] = [
        Feed(imageURL: URL(string: "https://blog.kakaocdn.net/dn/3x7MT/btqGY57LsGF/Ec2NJDHHv7Oo7rk08JPXD1/img.png")!, isLike: true),
        Feed(imageURL: URL(string: "https://blog.kakaocdn.net/dn/3x7MT/btqGY57LsGF/Ec2NJDHHv7Oo7rk08JPXD1/img.png")!, isLike: true)
    ]
 
    private let profileService: ProfileService = .init()
    
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
}
