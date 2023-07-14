//
//  ProfileImgView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import Kingfisher
import SwiftUI

struct ProfileImgView: View {
    var imageUrl: URL?

    var body: some View {
        if let imageUrl {
            KFImage(imageUrl)
                .placeholder { _ in
                    ProgressView()
                }
                .resizable()
                .clipShape(Circle())
        } else {
            Image("sns-default-profile-image-rectangle")
                .resizable()
                .clipShape(Circle())
        }
    }
}
