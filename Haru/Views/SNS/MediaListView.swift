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
                                    MediaView(uiImage: postVM.mediaImageList[mediaList[idx].id]?.first??.uiImage)
                                }

                                if !mediaList.isEmpty, postVM.page <= postVM.mediaTotalPage[postVM.selectedHashTag.id] ?? 0 {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .onAppear {
                                                print("더 불러오기")
                                                postVM.loadMorePosts()
                                            }
                                        Spacer()
                                    }
                                } else {
                                    Text("끝 \(postVM.page) \(postVM.mediaTotalPage[postVM.selectedHashTag.id] ?? 0)")
                                }
                            }
                        } else {
                            Text("아직 게시물이 존재하지 않습니다.")
                        }
                    }
                }, header: {
                    HashTagView(postVM: postVM)
                        .background(.white)
                })
            }
        }
        .onAppear {
            postVM.option = postVM.targetId == nil ? .media : postVM.selectedHashTag == Global.shared.hashTagAll ? .target_media : .target_media_hashtag
            postVM.fetchTargetHashTags()
            
            if postVM.mediaTotalPage[postVM.selectedHashTag.id] == nil {
                postVM.loadMorePosts()
            }
        }
        .background(.white)
    }
}
