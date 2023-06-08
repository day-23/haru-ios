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
                // 중요 태그
                StarButton(isClicked: true)
                    .onTapGesture {
                        self.action(Tag(id: DefaultTag.important.rawValue, content: DefaultTag.important.rawValue))
                    }

                // 완료 태그
                TagView(
                    tag: Tag(id: DefaultTag.completed.rawValue, content: DefaultTag.completed.rawValue),
                    isSelected: self.viewModel.selectedTag?.id == DefaultTag.completed.rawValue
                )
                .onTapGesture {
                    self.action(Tag(id: DefaultTag.completed.rawValue, content: DefaultTag.completed.rawValue))
                }

                // 태그 리스트들
                ForEach(self.viewModel.tagList) { tag in
                    if tag.isSelected {
                        TagView(tag: tag, isSelected: self.viewModel.selectedTag?.id == tag.id)
                            .onTapGesture {
                                self.action(tag)
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
