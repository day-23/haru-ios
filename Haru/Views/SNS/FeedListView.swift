//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    @StateObject var postVM: PostViewModel
    @Binding var postOptModalVis: (Bool, Post?)

    var comeToRoot: Bool = false

    var body: some View {
        Group {
            if postVM.postList.count > 0 {
                if comeToRoot {
                    comeFromMain()
                } else {
                    mainContent()
                }
            } else {
                VStack(spacing: 15) {
                    Spacer()
                    Image("sns-empty-feedlist")
                        .resizable()
                        .frame(width: 180, height: 125)

                    Text(postVM.option == .main ? "게시물을 작성해보세요." : "게시물이 아직 없어요.")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                    Spacer()
                }
            }
        }
        .onAppear {
            postVM.option = postVM.targetId == nil ? .main : .target_feed
            if postVM.feedTotalPage == -1 {
                postVM.loadMorePosts()
            }
        }
    }

    @ViewBuilder
    func comeFromMain() -> some View {
        ScrollView {
            mainContent()
        }
        .refreshable {
            postVM.refreshPosts()
        }
    }

    @ViewBuilder
    func mainContent() -> some View {
        LazyVStack(spacing: 14) {
            ForEach(postVM.postList) { post in
                if !post.disabled {
                    FeedView(
                        post: post,
                        postImageList: postVM.postImageList[post.id] ?? [],
                        postVM: postVM,
                        postOptModalVis: $postOptModalVis
                    )
                }
            }
            if !postVM.postList.isEmpty &&
                postVM.page <= postVM.feedTotalPage &&
                (postVM.option == .target_feed || postVM.option == .main)
            {
                HStack {
                    Spacer()
                    ProgressView()
                        .onAppear {
                            postVM.loadMorePosts()
                        }
                    Spacer()
                }
            }
        }
        .padding(.top, 14)
    }
}
