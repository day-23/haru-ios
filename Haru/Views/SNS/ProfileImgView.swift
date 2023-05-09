//
//  ProfileImgView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileImgView: View {
    var imageUrl: URL?

    var body: some View {
        AsyncImage(url: imageUrl, content: { image in
            image
                .resizable()
                
        }, placeholder: {
            Image(systemName: "person")
        })
        .clipShape(Circle())
    }
}

struct ProfileImgView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImgView(imageUrl: URL(string: "https://harus3.s3.ap-northeast-2.amazonaws.com/profile/1680693394711_momo.jpg")!)
    }
}
