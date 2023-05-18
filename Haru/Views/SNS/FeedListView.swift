//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    @StateObject var postVM: PostViewModel

    var comeToRoot: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(postVM.postList) { post in
                    FeedView(
                        post: post,
                        postImageList: postVM.postImageList[post.id] ?? [],
                        postVM: postVM,
                        comeToRoot: comeToRoot
                    )
                }
                if !postVM.postList.isEmpty, postVM.page <= postVM.feedTotalPage {
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                print("더 불러오기")
                                postVM.loadMorePosts()
                            }
                        Spacer()
                    }
                }
            }
            .padding(.top, 14)
        }
        .onAppear {
            postVM.option = postVM.targetId == nil ? .main : .target_feed

            if postVM.feedTotalPage == -1 {
                postVM.loadMorePosts()
            }
        }
        .refreshable {
            postVM.refreshPosts()
            postVM.loadMorePosts()
        }
    }
}
