//
//  FeedImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FeedImage: View {
//    var commentVM: CommentViewModel

    var post: Post
    var imageList: [PostImage?]
    var imageCount: Int
    var templateMode: Bool
    var contentColor: String? // 템플릿 게시물인 경우 black인지 white인지 받아줘야함
    var content: String?
    var isMine: Bool
    @State var postPageNum: Int = 0
    
    @Binding var commentModify: Bool

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
                ForEach(imageList.indices, id: \.self) { idx in
                    if let uiImage = imageList[idx]?.uiImage {
                        NavigationLink {
                            CommentView(
                                commentModify: $commentModify,
                                isTemplate: templateMode,
                                templateContent: content,
                                contentColor: contentColor,
                                postId: post.id,
                                userId: post.user.id,
                                postImageList: post.images,
                                imageList: imageList,
                                postPageNum: postPageNum,
                                isMine: isMine
                            )

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
                        .disabled(
                            !(isMine ||
                                post.user.isAllowFeedComment == 2 ||
                                (post.user.isAllowFeedComment == 1 &&
                                    post.user.friendStatus == 2))
                        )
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
