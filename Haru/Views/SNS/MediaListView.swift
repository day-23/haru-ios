//
//  MediaListView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/18.
//

import SwiftUI

struct MediaListView: View {
    @StateObject var postVM: PostViewModel

    var scrollable: Bool = true

    var body: some View {
        Group {
            if scrollable {
                scrollView()
            } else {
                VStack(spacing: 0) {
                    HashTagView(postVM: postVM)
                        .background(.white)
                        .padding(.bottom, 4)

                    content()
                }
            }
        }
        .onAppear {
            postVM.option = postVM.targetId == nil ? .mediaAll : postVM.selectedHashTag == Global.shared.hashTagAll ? .targetMediaAll : .targetMediaHashtag
            postVM.fetchTargetHashTags()

            if postVM.mediaTotalPage[postVM.selectedHashTag.id] == nil {
                postVM.loadMorePosts()
            }
        }
    }

    @ViewBuilder
    func scrollView() -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section(content: {
                    content()
                }, header: {
                    HashTagView(postVM: postVM)
                        .background(Color(0xfdfdfd))
                        .padding(.bottom, 4)
                })
            }
        }
        .refreshable {
            postVM.refreshPosts()
        }
    }

    @ViewBuilder
    func content() -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

        if let mediaList = postVM.mediaList[postVM.selectedHashTag.id] {
            if mediaList.count > 0 {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(mediaList.indices, id: \.self) { idx in
                        if !mediaList[idx].disabled {
                            NavigationLink {
                                MediaFeedView(
                                    post: mediaList[idx],
                                    postImageList: postVM.mediaImageList[mediaList[idx].id] ?? [],
                                    postVM: postVM
                                )

                            } label: {
                                MediaView(uiImage: postVM.mediaImageList[mediaList[idx].id]?.first??.uiImage)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if idx == mediaList.count - 1 {
                                    postVM.loadMorePosts()
                                }
                            }
                            .onReceive(postVM.$mediaList, perform: { value in
                                if postVM.mediaTotalItems[postVM.selectedHashTag.id] == value[postVM.selectedHashTag.id]?.count,
                                   !postVM.isEnd
                                {
                                    postVM.isEnd = true
                                    Global.shared.toastMessageContent = "최근 게시글을 모두 불러왔습니다."
                                    withAnimation {
                                        Global.shared.showToastMessage = true
                                    }
                                }
                            })
                        }
                    }
                }
            } else {
                VStack(spacing: 15) {
                    Spacer()
                        .padding(.bottom, 57)

                    Image("sns-empty-feedlist")
                        .resizable()
                        .frame(width: 180, height: 125)
                        .padding(.bottom, 64)

                    Text("나의 하루를 기록해 보세요.")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0xacacac))

                    Spacer()
                }
            }
        } else {
            VStack(spacing: 15) {
                Spacer()
                    .padding(.top, 57)

                Image("sns-empty-feedlist")
                    .resizable()
                    .frame(width: 180, height: 125)
                    .padding(.bottom, 64)

                Text("나의 하루를 기록해 보세요.")
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundColor(Color(0xacacac))

                Spacer()
            }
        }
    }
}
