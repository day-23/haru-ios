//
//  ProfileImgView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileImgView: View {
    var imageUrl: URL

    var body: some View {
        AsyncImage(url: imageUrl, content: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }, placeholder: {
            Image(systemName: "person")
        })
        .clipShape(Circle())
    }
}

struct ProfileImgView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImgView(imageUrl: URL(string: "https://item.kakaocdn.net/do/fd0050f12764b403e7863c2c03cd4d2d7154249a3890514a43687a85e6b6cc82")!)
    }
}
