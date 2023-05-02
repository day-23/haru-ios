//
//  MediaView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct MediaView: View {
    var body: some View {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    TagView(tag: Tag(id: UUID().uuidString, content: "하루 챌린지"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "음식"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "학교"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "오운완"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "홍대거리"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "먹방"))
                }
            }.padding(.horizontal, 16)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
            let width = UIScreen.main.bounds.size.width / 3
            LazyVGrid(columns: columns, alignment: .leading, spacing: 3) {
                ForEach(0 ..< 20, id: \.self) { _ in
                    AsyncImage(url: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "wifi.slash")
                    }
                    .frame(width: width, height: width)
                }
            }
        }
    }
}

struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        MediaView()
    }
}
