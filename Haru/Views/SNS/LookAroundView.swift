//
//  LookAroundView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct LookAroundView: View {
    @StateObject var postVM = PostViewModel(option: .media_all)
    var body: some View {
        VStack(spacing: 0) {
            MediaListView(postVM: postVM)
        }
        .background(Color(0xfdfdfd))
        .onAppear {
            postVM.fetchPopularHashTags()
        }
    }
}
