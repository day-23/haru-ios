//
//  MediaView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct MediaView: View {
    @StateObject var postVM: PostViewModel

    var body: some View {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(postVM.hashTags.indices, id: \.self) { idx in
                        Text(postVM.hashTags[idx].content)
                            .font(.pretendard(size: 16, weight: .bold))
                            .foregroundColor(
                                postVM.hashTags[idx] == postVM.selectedHashTag
                                    ? .white
                                    : Color(0x191919)
                            )
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(
                                postVM.hashTags[idx] == postVM.selectedHashTag
                                    ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color(0xFDFDFD)], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]),
                                        lineWidth: 1
                                    )
                            )
                            .onTapGesture {
                                postVM.selectedHashTag = postVM.hashTags[idx]
                            }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            mediaListView()
        }
        .background(.white)
    }

    @ViewBuilder
    func mediaListView() -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)
        let width = (UIScreen.main.bounds.size.width - 6) / 3
        if let mediaList = postVM.mediaList[postVM.selectedHashTag.id] {
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(mediaList.indices, id: \.self) { idx in
                    if let uiImage = postVM.mediaImageList[mediaList[idx].id]?[0]?.uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: width, height: width)
                    } else {
                        ProgressView()
                            .frame(width: width, height: width)
                    }
                }
                if !postVM.mediaList.isEmpty, (postVM.mediaPage + 1) <= postVM.mediaTotalPages {
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                print("더 불러오기")
                                postVM.loadMorePosts(option: .target_media)
                            }
                        Spacer()
                    }
                }
            }
        } else {
            Text("아직 게시한 미디어가 없습니다")
        }
    }
}

// struct MediaView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaView()
//    }
// }
