//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    @StateObject var postVM: PostViewModel

    var body: some View {
        ScrollView {
            VStack {
                ForEach(postVM.postList) { post in
                    FeedView(post: post)
                }
            }
        }
    }
}
