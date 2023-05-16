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
    var profileImage: PostImage?

    @StateObject var postVM: PostViewModel

    var comeToRoot: Bool = false
    var isMine: Bool {
        post.user.id == Global.shared.user?.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                NavigationLink {
                    ProfileInfoView(
                        postVM: PostViewModel(targetId: post.user.id),
                        userProfileVM: UserProfileViewModel(userId: post.user.id)
                    )
                } label: {
                    HStack {
                        ProfileImgView(profileImage: profileImage)
                            .frame(width: 30, height: 30)

                        Text("\(post.user.name)")
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(.mainBlack)
                    }
                }.disabled(!comeToRoot)

                Text("1일 전")
                    .font(.pretendard(size: 10, weight: .regular))
                    .foregroundColor(.gray2)

                Spacer()

                Image("ellipsis")
                    .renderingMode(.template)
                    .foregroundColor(.gray1)
            }
            .padding(.horizontal, 20)

            FeedImage(imageList: postImageList, imageCount: post.images.count, templateMode: post.templateUrl != nil, content: post.content)

            HStack(spacing: 22) {
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
                        Image(systemName: "ellipses.bubble")
                            .foregroundColor(post.isCommented ? .gradientStart1 : .gray2)
                    }

                    if isMine {
                        Text("\(post.commentCount)")
                            .font(.pretendard(size: 14, weight: .bold))
                    }
                }

                Spacer()

                if Global.shared.user?.id == post.user.id {
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
