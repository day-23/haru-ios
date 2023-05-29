//
//  FeedView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedView: View {
    var post: Post
    var postImageList: [PostImage?]

    @StateObject var postVM: PostViewModel

    var comeToRoot: Bool = false
    var isMine: Bool {
        post.user.id == Global.shared.user?.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                NavigationLink {
                    ProfileView(
                        postVM: PostViewModel(targetId: post.user.id, option: .target_feed),
                        userProfileVM: UserProfileViewModel(userId: post.user.id)
                    )
                } label: {
                    HStack {
                        ProfileImgView(profileImage: postVM.profileImage)
                            .frame(width: 30, height: 30)

                        Text("\(post.user.name)")
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(.mainBlack)
                    }
                }.disabled(!comeToRoot)

                Text("1일 전")
                    .font(.pretendard(size: 10, weight: .regular))
                    .foregroundColor(Color(0x646464))

                Spacer()

                Image("ellipsis")
                    .renderingMode(.template)
                    .foregroundColor(Color(0xDBDBDB))
            }
            .padding(.horizontal, 20)

            FeedImage(
                post: post,
                imageList: postImageList,
                imageCount: post.images.count,
                templateMode: post.templateUrl != nil,
                content: post.content,
                isMine: isMine
            )

            HStack(spacing: 14) {
                HStack(spacing: 10) {
                    Button {
                        postVM.likeThisPost(targetPostId: post.id)
                    } label: {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                    }

                    if isMine {
                        Text("\(post.likedCount)")
                            .font(.pretendard(size: 14, weight: .bold))
                    }
                }

                HStack(spacing: 10) {
                    NavigationLink {
                        CommentView(
                            postId: post.id,
                            postImageList: post.images,
                            imageList: postImageList,
                            isMine: isMine
                        )
                    } label: {
                        // TODO: post.isCommented인 경우 chat-bubble-fill : chat-bubble
                        Image("chat-bubble-fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }

                    if isMine {
                        Text("\(post.commentCount)")
                            .font(.pretendard(size: 14, weight: .bold))
                    }
                }

                Spacer()

                if isMine {
                    Image("option-button")
                        .renderingMode(.template)
                        .foregroundColor(.gray2)
                }
            }
            .padding(.horizontal, 20)

            if let content = post.content, post.templateUrl == nil {
                Text(content)
                    .lineLimit(nil)
                    .font(.pretendard(size: 14, weight: .regular))
                    .padding(.horizontal, 20)
            }
            Divider()
        }
    }
}
