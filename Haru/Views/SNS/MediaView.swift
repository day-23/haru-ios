//
//  MediaView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct MediaView: View {
    var body: some View {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    TagView(tag: Tag(id: UUID().uuidString, content: "하루 챌린지"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "음식"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "학교"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "오운완"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "홍대거리"))
                    TagView(tag: Tag(id: UUID().uuidString, content: "먹방"))
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        MediaView()
    }
}
