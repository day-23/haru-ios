//
//  FeedImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FeedImage: View {
    var imageList: [Post.Image]
    @State var postPageNum: Int = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("\(postPageNum + 1)/\(imageList.count)")
                .font(.pretendard(size: 12, weight: .bold))
                .foregroundColor(.mainBlack)
                .padding(.all, 6)
                .background(Color.white.opacity(0.5))
                .cornerRadius(15)
                .offset(x: -10, y: 10)
                .zIndex(2)

            TabView(selection: $postPageNum) {
                ForEach(imageList.indices, id: \.self) { idx in
                    AsyncImage(url: URL(string: imageList[idx].url)) { image in
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

//struct FeedImage_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedImage(imageUrl: URL(string: "https://cdn.hankooki.com/news/photo/202301/46144_62027_1673489105.jpg")!)
//    }
//}
