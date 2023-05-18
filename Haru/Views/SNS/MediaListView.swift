//
//  MediaListView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/18.
//

import SwiftUI

struct MediaListView: View {
    @StateObject var postVM: PostViewModel
    
    @State var page: Int = 1
    @State var totalPage: Int = 0
    @State var lastCreatedAt: Date? = nil

    var postOption: PostOption
    
    var body: some View {
        ScrollView {
            HashTagView(postVM: postVM)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)
            
            if let mediaList = postVM.mediaList[postVM.selectedHashTag.id] {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(mediaList.indices, id: \.self) { idx in
                        MediaView(uiImage: postVM.mediaImageList[mediaList[idx].id]?[0]?.uiImage)
                    }
                    
                    if !postVM.mediaList.isEmpty, page <= totalPage {
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
            } else {
                Text("아직 게시한 미디어가 없습니다")
            }
        }
        .onAppear {
            postVM.fetchTargetHashTags()
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
    }
}
