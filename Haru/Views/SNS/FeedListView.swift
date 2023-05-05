//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    var snsVM: SNSViewModel
    var postList: [Post]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(postList) { post in
                    FeedView(post: post, snsVM: snsVM)
                }
            }
        }
    }
}
