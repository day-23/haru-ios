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
    @Binding var postOptModalVis: (Bool, Post?)

    var comeToRoot: Bool = false
    var isMine: Bool {
        post.user.id == Global.shared.user?.id
    }
    
    var body: some View {
        ZStack {
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
                    
                    Button {
                        withAnimation {
                            postOptModalVis.0 = true
                            postOptModalVis.1 = post
                        }
                    } label: {
                        Image("ellipsis")
                            .renderingMode(.template)
                            .foregroundColor(Color(0xdbdbdb))
                    }
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
                    HStack(spacing: 9) {
                        Button {
                            postVM.likeThisPost(targetPostId: post.id)
                        } label: {
                            Image(post.isLiked ? "heart-fill" : "heart-empty")
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .disabled(
                            !(isMine ||
                                post.user.isAllowFeedLike == 2 ||
                                (post.user.isAllowFeedLike == 1 &&
                                    post.user.friendStatus == 2))
                        )
                        
                        if isMine {
                            Text("\(post.likedCount)")
                                .font(.pretendard(size: 14, weight: .bold))
                        }
                    }
                    
                    HStack(spacing: 10) {
                        NavigationLink {
                            CommentView(
                                postId: post.id,
                                userId: post.user.id,
                                postImageList: post.images,
                                imageList: postImageList,
                                isMine: isMine
                            )
                        } label: {
                            // TODO: post.isCommented인 경우 chat-bubble-fill : chat-bubble
                            Image(post.commentCount > 0 ? "chat-bubble-fill" : "chat-bubble-empty")
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
                        NavigationLink {
                            CommentListView(
                                commentVM: CommentViewModel(
                                    userId: post.user.id,
                                    postImageIDList: post.images.map { image in
                                        image.id
                                    },
                                    postId: post.id,
                                    imagePageNum: 0
                                )
                            )
                        } label: {
                            Image("option-button")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 28, height: 28)
                                .foregroundColor(.gray2)
                        }
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
        .background(Color(0xfdfdfd))
    }
}
