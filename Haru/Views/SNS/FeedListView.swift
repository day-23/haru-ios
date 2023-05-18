//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    @StateObject var postVM: PostViewModel

    @State var page: Int = 1
    @State var totalPage: Int = 0
    @State var lastCreatedAt: Date? = nil

    var postOption: PostOption

    var comeToRoot: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(postVM.postList) { post in
                    FeedView(post: post, postImageList: postVM.postImageList[post.id] ?? [], postVM: postVM, comeToRoot: comeToRoot)
                }
                if !postVM.postList.isEmpty, page <= totalPage {
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                print("더 불러오기")
                                postVM.loadMorePosts(
                                    option: postOption,
                                    page: page,
                                    totalPage: totalPage,
                                    lastCreatedAt: lastCreatedAt,
                                    isAppear: false
                                ) {
                                    self.page += 1
                                    self.totalPage = $0
                                    self.lastCreatedAt = $1
                                }
                            }
                        Spacer()
                    }
                }
            }
            .padding(.top, 14)
        }
        .onAppear {
            print("[Debug] 피드 리스트 처음 불러오기 \(#fileID)")
            postVM.loadMorePosts(
                option: postOption,
                page: page,
                totalPage: totalPage,
                isAppear: true
            ) {
                self.page += 1
                self.totalPage = $0
                self.lastCreatedAt = $1
            }
        }
        .refreshable {
            postVM.refreshPosts(option: postOption)
            page = 1
            postVM.loadMorePosts(option: postOption, page: page, totalPage: totalPage, isAppear: true) {
                self.page += 1
                self.totalPage = $0
                self.lastCreatedAt = $1
            }
        }
    }
}
