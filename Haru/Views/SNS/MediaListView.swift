//
//  MediaListView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/18.
//

import SwiftUI

struct MediaListView: View {
    @StateObject var postVM: PostViewModel

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section(content: {
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

                    if let mediaList = postVM.mediaList[postVM.selectedHashTag.id] {
                        if mediaList.count > 0 {
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(mediaList.indices, id: \.self) { idx in
                                    NavigationLink {
                                        CommentView(
                                            postId: mediaList[idx].id,
                                            userId: mediaList[idx].user.id,
                                            postImageList: mediaList[idx].images,
                                            imageList: postVM.mediaImageList[mediaList[idx].id] ?? [],
                                            postPageNum: 0,
                                            hideAllComment: true,
                                            isMine: mediaList[idx].user.id == Global.shared.user?.id
                                        )

                                    } label: {
                                        MediaView(uiImage: postVM.mediaImageList[mediaList[idx].id]?.first??.uiImage)
                                    }
                                    .buttonStyle(.plain)
                                }

                                if !mediaList.isEmpty,
                                   postVM.page <= postVM.mediaTotalPage[postVM.selectedHashTag.id] ?? 0,
                                   postVM.option == .media_all || postVM.option == .media_hashtag
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
                        } else {
                            Text("아직 게시물이 존재하지 않습니다.")
                        }
                    }
                }, header: {
                    HashTagView(postVM: postVM)
                        .background(Color(0xfdfdfd))
                })
            }
        }
        .onAppear {
            postVM.option = postVM.targetId == nil ? .media_all : postVM.selectedHashTag == Global.shared.hashTagAll ? .target_media_all : .target_media_hashtag
            postVM.fetchTargetHashTags()

            if postVM.mediaTotalPage[postVM.selectedHashTag.id] == nil {
                postVM.loadMorePosts()
            }
        }
    }
}
