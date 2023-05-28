//
//  FeedImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FeedImage: View {
    var imageList: [PostImage?]
    var imageCount: Int
    var templateMode: Bool
    var content: String?
    @State var postPageNum: Int = 0

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        ZStack {
            if !templateMode {
                Text("\(postPageNum + 1)/\(imageCount)")
                    .font(.pretendard(size: 12, weight: .bold))
                    .foregroundColor(Color(0xFDFDFD))
                    .padding(.all, 6)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: -10, y: 10)
                    .zIndex(2)
            } else if let content {
                Text(content)
                    .lineLimit(nil)
                    .font(.pretendard(size: 14, weight: .regular))
                    .padding(.all, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .zIndex(2)
            }

            TabView(selection: $postPageNum) {
                ForEach(imageList.indices, id: \.self) { idx in
                    if let uiImage = imageList[idx]?.uiImage {
                        Image(uiImage: uiImage)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height
                            )
                            .clipped()
                    } else {
                        ProgressView()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .zIndex(1)
        }
        .clipped()
        .frame(width: deviceSize.width, height: deviceSize.width, alignment: .center)
    }
}

// struct FeedImage_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedImage(imageUrl: URL(string: "https://cdn.hankooki.com/news/photo/202301/46144_62027_1673489105.jpg")!)
//    }
// }
