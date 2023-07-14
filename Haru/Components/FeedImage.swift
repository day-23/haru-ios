//
//  FeedImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import Kingfisher
import SwiftUI

struct FeedImage: View {
    @Binding var post: Post
    var imageUrlList: [URL?]
    var imageCount: Int
    var templateMode: Bool
    var contentColor: String? // 템플릿 게시물인 경우 black인지 white인지 받아줘야함
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
                    .padding(.horizontal, 14)
                    .background(Color(0x191919).opacity(0.5))
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: -10, y: 10)
                    .zIndex(2)
            } else if let content {
                Text(content)
                    .lineLimit(nil)
                    .font(.pretendard(size: 24, weight: .bold))
                    .foregroundColor(Color(contentColor))
                    .padding(.all, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(2)
            }

            TabView(selection: $postPageNum) {
                ForEach(imageUrlList.indices, id: \.self) { idx in
                    NavigationLink {
                        CommentView(
                            post: $post,
                            isTemplate: templateMode,
                            templateContent: content,
                            contentColor: contentColor,
                            postId: post.id,
                            userId: post.user.id,
                            postImageList: post.images,
                            imageUrlList: imageUrlList,
                            commentList: Array(repeating: [Post.Comment](), count: post.images.count),
                            postPageNum: postPageNum,
                            isMine: isMine
                        )

                    } label: {
                        GeometryReader { geo in
                            if let imageURL = imageUrlList[idx] {
                                if post.images[idx].mimeType == "image/gif" {
                                    GifImage(url: imageURL, data: try? Data(contentsOf: imageURL))
                                } else {
                                    KFImage(imageURL)
                                        .downsampling(
                                            size: CGSize(
                                                width: geo.size.width * UIScreen.main.scale,
                                                height: geo.size.width * UIScreen.main.scale
                                            )
                                        )
                                        .placeholder { _ in
                                            ProgressView()
                                        }
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .clipped()
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .zIndex(1)
        }
        .clipped()
        .frame(width: deviceSize.width, height: deviceSize.width, alignment: .center)
    }
}
