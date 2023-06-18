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
                        }
                    }

                    if !mediaList.isEmpty,
                       postVM.page <= postVM.mediaTotalPage[postVM.selectedHashTag.id] ?? 0,
                       postVM.option == .mediaAll || postVM.option == .mediaHashtag
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
                VStack(spacing: 15) {
                    Spacer()
                        .padding(.bottom, 57)

                    Image("sns-empty-feedlist")
                        .resizable()
                        .frame(width: 180, height: 125)
                        .padding(.bottom, 64)

                    Text("나의 하루를 기록해 보세요.")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))

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
                    .foregroundColor(Color(0x646464))

                Spacer()
            }
        }
    }
}
