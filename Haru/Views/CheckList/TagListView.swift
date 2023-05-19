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
                        action(Tag(id: DefaultTag.important.rawValue, content: DefaultTag.important.rawValue))
                    }

                // 미분류 태그
                TagView(
                    tag: Tag(id: DefaultTag.unclassified.rawValue, content: DefaultTag.unclassified.rawValue),
                    isSelected: viewModel.selectedTag?.id == DefaultTag.unclassified.rawValue
                )
                .onTapGesture {
                    action(Tag(id: DefaultTag.unclassified.rawValue, content: DefaultTag.unclassified.rawValue))
                }

                // 완료 태그
                TagView(
                    tag: Tag(id: DefaultTag.completed.rawValue, content: DefaultTag.completed.rawValue),
                    isSelected: viewModel.selectedTag?.id == DefaultTag.completed.rawValue
                )
                .onTapGesture {
                    action(Tag(id: DefaultTag.completed.rawValue, content: DefaultTag.completed.rawValue))
                }

                // 태그 리스트들
                ForEach(viewModel.tagList) { tag in
                    if let isSelected = tag.isSelected, isSelected {
                        TagView(tag: tag, isSelected: viewModel.selectedTag?.id == tag.id)
                            .onTapGesture {
                                action(tag)
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
