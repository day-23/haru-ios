//
//  FeedListView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct FeedListView: View {
    var snsVM: SNSViewModel
    @Binding var feedList: [Feed]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(feedList) { feed in
                    FeedView(feed: feed, snsVM: snsVM)
                }
            }
        }
    }
}
