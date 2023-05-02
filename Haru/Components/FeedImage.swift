//
//  FeedImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FeedImage: View {
    var imageUrl: URL
    var endPageNum: Int = 10
    @State var pageNum: Int = 1

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("\(pageNum)/\(endPageNum)")
                .font(.pretendard(size: 12, weight: .bold))
                .foregroundColor(.mainBlack)
                .padding(.all, 6)
                .background(Color.white.opacity(0.5))
                .cornerRadius(15)
                .offset(x: -10, y: 10)
                .zIndex(2)

            TabView(selection: $pageNum) {
                ForEach(0 ... endPageNum, id: \.self) { _ in
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                    } placeholder: {
                        Image(systemName: "wifi.slash")
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 395, height: 390)
            .zIndex(1)
        }
    }
}

struct FeedImage_Previews: PreviewProvider {
    static var previews: some View {
        FeedImage(imageUrl: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!)
    }
}
