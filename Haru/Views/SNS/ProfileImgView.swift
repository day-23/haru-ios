//
//  ProfileImgView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileImgView: View {
    var profileImage: PostImage?
    var imageUrl: URL?

    var body: some View {
        if let imageUrl {
            // 팔로우, 팔로윙 목록의 프로필은 캐싱하지 않고 asyncImage 사용
            AsyncImage(url: imageUrl) { image in
                image
                    .resizable()
            } placeholder: {
                Image("sns-default-profile-image-rectangle")
                    .resizable()
            }
            .clipShape(Circle())
        } else {
            // 상대적으로 적은 수의 프로필은 캐싱
            if let profileImage {
                Image(uiImage: profileImage.uiImage)
                    .resizable()
                    .clipShape(Circle())
            } else {
                Image("sns-default-profile-image-rectangle")
                    .resizable()
                    .clipShape(Circle())
            }
        }
    }
}
