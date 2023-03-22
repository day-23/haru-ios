//
//  TagListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct TagListView: View {
    let viewModel: CheckListViewModel
    let action: (Tag) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                //  중요 태그
                StarButton(isClicked: true)
                    .onTapGesture {
                        action(Tag(id: "중요", content: "중요"))
                    }

                //  미분류 태그
                TagView(Tag(id: "미분류", content: "미분류"))
                    .onTapGesture {
                        action(Tag(id: "미분류", content: "미분류"))
                    }

                //  완료 태그
                TagView(Tag(id: "완료", content: "완료"))
                    .onTapGesture {
                        action(Tag(id: "완료", content: "완료"))
                    }

                //  태그 리스트들
                ForEach(viewModel.tagList) { tag in
                    TagView(tag)
                        .onTapGesture {
                            action(tag)
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
