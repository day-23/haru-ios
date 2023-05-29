//
//  FeedImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FeedImage: View {
    var post: Post
    var imageList: [PostImage?]
    var imageCount: Int
    var templateMode: Bool
    var content: String?
    var isMine: Bool
    @State var postPageNum: Int = 0

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        ZStack {
            if !templateMode {
                Text("\(postPageNum + 1)/\(imageCount)")
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundColor(Color(0xFDFDFD))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(0xFDFDFD).opacity(0.5))
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
                        NavigationLink {
                            if !templateMode {
                                CommentView(
                                    postId: post.id,
                                    postImageList: post.images,
                                    imageList: imageList,
                                    postPageNum: postPageNum,
                                    isMine: isMine
                                )
                            } else {
                                Text("댓글 리스트")
                            }
                        } label: {
                            Image(uiImage: uiImage)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: UIScreen.main.bounds.width,
                                    height: UIScreen.main.bounds.height
                                )
                                .clipped()
                        }
                        .buttonStyle(.plain)
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
