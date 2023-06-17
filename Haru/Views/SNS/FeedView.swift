//
//  FeedView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedView: View {
    @State var post: Post
    var postImageList: [PostImage?]

    @StateObject var postVM: PostViewModel
    @Binding var postOptModalVis: (Bool, Post?)

    var isMine: Bool {
        post.user.id == Global.shared.user?.id
    }
    
    var body: some View {
        let commentVM = CommentViewModel(
            userId: post.user.id,
            postImageIDList: post.images.map { image in
                image.id
            },
            postId: post.id,
            imagePageNum: 0
        )
        
        return ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    NavigationLink {
                        ProfileView(
                            postVM: PostViewModel(targetId: post.user.id, option: .target_feed),
                            userProfileVM: UserProfileViewModel(userId: post.user.id)
                        )
                    } label: {
                        HStack {
                            ProfileImgView(profileImage: postVM.profileImageList[post.id] ?? nil)
                                .frame(width: 30, height: 30)
                            
                            Text("\(post.user.name)")
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(.mainBlack)
                        }
                    }.disabled(
                        postVM.option == .target_feed ||
                            postVM.option == .target_media_all ||
                            postVM.option == .target_media_hashtag
                    )
                    
                    Text("\(post.createdAt.relative())")
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x646464))
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            postOptModalVis.0 = true
                            postOptModalVis.1 = post
                        }
                    } label: {
                        Image("more")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x646464))
                    }
                }
                .padding(.horizontal, 20)
                
                FeedImage(
                    post: post,
                    imageList: postImageList,
                    imageCount: post.images.count,
                    templateMode: post.isTemplatePost != nil,
                    contentColor: post.isTemplatePost ?? "",
                    content: post.content,
                    isMine: isMine
                )
                .padding(.top, 14)
                .padding(.bottom, 10)
                
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Button {
                            postVM.likeThisPost(targetPostId: post.id) {
                                if post.isLiked {
                                    post.likedCount -= 1
                                    post.isLiked = false
                                } else {
                                    post.likedCount += 1
                                    post.isLiked = true
                                }
                            }
                        } label: {
                            Image(post.isLiked ? "sns-heart-fill" : "sns-heart")
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
                                .foregroundColor(Color(0x191919))
                        }
                    }
                    
                    HStack(spacing: 5) {
                        NavigationLink {
                            CommentView(
                                isTemplate: post.isTemplatePost != nil,
                                templateContent: post.content,
                                contentColor: post.isTemplatePost ?? "",
                                postId: post.id,
                                userId: post.user.id,
                                postImageList: post.images,
                                imageList: postImageList,
                                commentList: Array(repeating: [Post.Comment](), count: post.images.count),
                                postPageNum: 0,
                                isMine: isMine
                            )
                        } label: {
                            if post.isCommented {
                                Image("sns-comment-fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            } else {
                                Image("sns-comment-empty")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(Color(0xacacac))
                            }
                        }
                        
                        if isMine {
                            Text("\(post.commentCount)")
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(Color(0x191919))
                        }
                    }
                    
                    Spacer()
                    
                    if isMine {
                        NavigationLink {
                            CommentListView(
                                commentVM: commentVM,
                                isTemplate: post.isTemplatePost != nil
                            )
                        } label: {
                            Image("slider")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 28, height: 28)
                                .foregroundColor(Color(0x191919))
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                if let content = post.content,
                   post.isTemplatePost == nil,
                   !content.isEmpty
                {
                    Text(content)
                        .lineLimit(nil)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x191919))
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                
                Divider()
                    .padding(.top, 15)
            }
        }
    }
}
