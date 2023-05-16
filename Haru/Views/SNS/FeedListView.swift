//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    @StateObject var postVM: PostViewModel
    @State var isAppear: Bool = false

    var comeToRoot: Bool = false
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(postVM.postList) { post in
                    FeedView(post: post, postImageList: postVM.postImageList[post.id] ?? [], postVM: postVM, comeToRoot: comeToRoot)
                }
                if !postVM.postList.isEmpty, (postVM.feedPage + 1) <= postVM.feedTotalPages {
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                print("더 불러오기")
                                postVM.loadMorePosts(
                                    option: postVM.targetId != nil ? .target_feed : .main
                                )
                            }
                        Spacer()
                    }
                }
            }
            .padding(.top, 14)
        }.refreshable {
            print("새로고침")
            postVM.refreshPosts(
                option: postVM.targetId != nil ? .target_feed : .main
            )
        }
    }
}
