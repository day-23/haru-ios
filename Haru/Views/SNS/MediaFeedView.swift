//
//  MediaFeedView.swift
//  Haru
//
//  Created by 이준호 on 2023/06/14.
//

import SwiftUI

struct MediaFeedView: View {
    @Environment(\.dismiss) var dismissAction

    var post: Post
    var postImageList: [PostImage?]
    @StateObject var postVM: PostViewModel

    var body: some View {
        VStack {
            FeedView(
                post: post,
                postImageList: postImageList,
                postVM: postVM,
                postOptModalVis: .constant((true, post))
            )
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(0xfdfdfd))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                }
            }
        }
    }
}
