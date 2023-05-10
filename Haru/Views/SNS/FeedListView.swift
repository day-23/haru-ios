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

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(postVM.postList) { post in
                    FeedView(post: post)
                }
                if !postVM.postList.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                print("여기")
                                postVM.loadMorePosts()
                            }
                        Spacer()
                    }
                }
            }
        }.onAppear {
            guard !isAppear else { return }
            isAppear = true
            postVM.loadMorePosts()
        }
    }
}
