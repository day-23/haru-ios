//
//  TagManageView.swift
//  Haru
//
//  Created by 최정민 on 2023/04/24.
//

import SwiftUI

struct TagManageView: View {
    private let width = UIScreen.main.bounds.width * 0.78
    private let height = UIScreen.main.bounds.height * 0.8

    @StateObject var checkListViewModel: CheckListViewModel
    @State private var offset = CGSize.zero
    @Binding var isActive: Bool
    @State private var addButtonTapped = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("태그 관리")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.pretendard(size: 20, weight: .bold))
                        .foregroundColor(Color(0xf8f8fa))
                }
                .padding(.top, 28)
                .padding(.horizontal, 30)
                .padding(.bottom, 18)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 9) {
                            HStack(spacing: 0) {
                                TextField("", text: $checkListViewModel.tagContent)
                                    .placeholder(when: checkListViewModel.tagContent.isEmpty) {
                                        Text("태그 추가")
                                            .font(.pretendard(size: 16, weight: .regular))
                                            .foregroundColor(
                                                checkListViewModel.tagContent.isEmpty ? Color(0xacacac) : Color(0x191919)
                                            )
                                    }
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .foregroundColor(
                                        checkListViewModel.tagContent.isEmpty ? Color(0xacacac) : Color(0x191919)
                                    )
                                    .onChange(
                                        of: checkListViewModel.tagContent,
                                        perform: onChangeTag(_:)
                                    )
                                    .onSubmit(onSubmitTag)

                                Spacer()

                                Button {
                                    if addButtonTapped ||
                                        checkListViewModel.tagContent.trimmingCharacters(in: .whitespaces).isEmpty
                                    {
                                        return
                                    }
                                    addButtonTapped = true

                                    checkListViewModel.addTag(
                                        content: checkListViewModel.tagContent
                                    ) { result in
                                        switch result {
                                        case .success:
                                            checkListViewModel.tagContent = ""
                                            addButtonTapped = false
                                        case .failure:
                                            addButtonTapped = false
                                        }
                                    }
                                } label: {
                                    Image("todo-add-sub-todo")
                                        .renderingMode(.template)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(0x191919))
                                }
                                .disabled(addButtonTapped)
                            }
                            .padding(.leading, 5)

                            ForEach($checkListViewModel.tagList) { $tag in
                                TagOptionItem(
                                    checkListViewModel: checkListViewModel,
                                    tag: tag
                                )
                            }
                        }
                        .padding(.top, 18)
                        .padding(.leading, 35)
                        .padding(.trailing, 30)
                    }
                }
                .frame(width: width, height: height * 0.86)
                .background(Color(0xfdfdfd))

                Spacer(minLength: 26)
            }
        }
        .frame(width: width, height: height)
        .background(
            Image("background-manage")
                .resizable()
        )
        .cornerRadius(10, corners: [.topLeft, .bottomLeft])
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.startLocation.x - value.location.x > 0 {
                        return
                    }
                    offset = CGSize(width: value.translation.width, height: offset.height)
                }
                .onEnded { value in
                    withAnimation {
                        if value.translation.width > width * 0.5 {
                            isActive = false
                        }
                        offset = .zero
                    }
                }
        )
    }
}

private struct TagOptionItem: View {
    @StateObject var checkListViewModel: CheckListViewModel

    var tag: Tag

    var body: some View {
        HStack(spacing: 0) {
            TagView(
                tag: tag,
                isHidden: !tag.isSelected
            )
            .onTapGesture {
                checkListViewModel.toggleVisibility(
                    tagId: tag.id,
                    isSeleted: tag.isSelected
                ) { result in
                    switch result {
                    case .success:
                        break
                    case .failure:
                        break
                    }
                }
            }

            Spacer()

            Image(tag.isSelected ? "todo-tag-visible" : "todo-tag-hidden")
                .padding(.trailing, 10)
                .onTapGesture {
                    checkListViewModel.toggleVisibility(
                        tagId: tag.id,
                        isSeleted: tag.isSelected
                    ) { result in
                        switch result {
                        case .success:
                            break
                        case .failure:
                            break
                        }
                    }
                }

            NavigationLink {
                TagDetailView(
                    checkListViewModel: _checkListViewModel,
                    tagId: tag.id,
                    content: tag.content,
                    onAlarm: true,
                    isSelected: tag.isSelected
                )
            } label: {
                Image("todo-edit-button\(tag.isSelected ? "" : "-disable")")
                    .frame(width: 28, height: 28)
            }
        }
    }
}

extension TagManageView {
    func onChangeTag(_: String) {
        let trimTag = checkListViewModel.tagContent.trimmingCharacters(in: .whitespaces)

        if trimTag.count > 8 {
            checkListViewModel.tagContent = String(trimTag[trimTag.startIndex ..< trimTag.index(trimTag.endIndex, offsetBy: -1)])
        }

        if !trimTag.isEmpty,
           checkListViewModel.tagContent[
               checkListViewModel.tagContent.index(checkListViewModel.tagContent.endIndex, offsetBy: -1)
           ] == " "
        {
            if checkListViewModel.tagList.filter({ $0.content == trimTag }).isEmpty {
                checkListViewModel.addTag(
                    content: trimTag
                ) { result in
                    switch result {
                    case .success:
                        break
                    case .failure:
                        break
                    }
                }
            }
            checkListViewModel.tagContent = ""
        }
    }

    func onSubmitTag() {
        let trimTag = checkListViewModel.tagContent.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty {
            if checkListViewModel.tagList.filter({ $0.content == trimTag }).isEmpty {
                checkListViewModel.addTag(
                    content: trimTag
                ) { result in
                    switch result {
                    case .success:
                        break
                    case .failure:
                        break
                    }
                }
            }
            checkListViewModel.tagContent = ""
        }
    }
}
