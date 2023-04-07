//
//  FeedView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct Feed: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let imageURL: URL
    let isLike: Bool
}

struct FeedView: View {
    var feed: Feed
    var snsVM: SNSViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ProfileImgView(imageUrl: URL(string: "https://item.kakaocdn.net/do/fd0050f12764b403e7863c2c03cd4d2d7154249a3890514a43687a85e6b6cc82")!)
                    .frame(width: 30, height: 30)

                Text("게으름민수")
                    .font(.pretendard(size: 14, weight: .bold))
                    .foregroundColor(.mainBlack)
                Text("1일 전")
                    .font(.pretendard(size: 10, weight: .regular))
                    .foregroundColor(.gray2)
                Spacer()
                Image("ellipsis")
                    .renderingMode(.template)
                    .foregroundColor(.gray1)
            }
            .padding(.horizontal, 20)

            AsyncImage(url: feed.imageURL) { image in
                image
                    .resizable()
            } placeholder: {
                Image(systemName: "wifi.slash")
            }
            .frame(width: 395, height: 390)

            HStack(spacing: 22) {
                Image(systemName: feed.isLike ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                Image(systemName: "ellipses.bubble")
                    .foregroundColor(.gray2)
                Spacer()
                Image("option-button")
                    .renderingMode(.template)
                    .foregroundColor(.gray2)
            }
            .padding(.horizontal, 20)
            Divider()
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(feed: Feed(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: true), snsVM: SNSViewModel())
    }
}
