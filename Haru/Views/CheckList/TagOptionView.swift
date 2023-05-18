//
//  TagOptionView.swift
//  Haru
//
//  Created by 최정민 on 2023/04/24.
//

import SwiftUI

struct TagOptionView: View {
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
                        .foregroundColor(Color(0xF8F8FA))

                    Image("confirm")
                        .renderingMode(.template)
                        .foregroundColor(Color(0xF8F8FA))
                        .onTapGesture {
                            withAnimation {
                                isActive = false
                            }
                        }
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .padding(.bottom, 18)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 9) {
                            HStack(spacing: 0) {
                                TextField("태그 추가", text: $checkListViewModel.tagContent)
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .foregroundColor(
                                        checkListViewModel.tagContent.isEmpty ? Color(0xACACAC) : Color(0x191919)
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
                                        case .failure(let error):
                                            print("[Debug] \(error) \(#fileID), \(#function)")
                                            addButtonTapped = false
                                        }
                                    }
                                } label: {
                                    Image("plus")
                                        .renderingMode(.template)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(0x191919))
                                }
                                .disabled(addButtonTapped)
                            }

                            ForEach($checkListViewModel.tagList) { $tag in
                                TagOptionItem(tag: tag) {
                                    checkListViewModel.toggleVisibility(
                                        tagId: tag.id,
                                        isSeleted: tag.isSelected ?? true
                                    ) { result in
                                        switch result {
                                        case .success:
                                            break
                                        case .failure(let error):
                                            print("[Debug] \(error) \(#fileID) \(#function)")
                                        }
                                    }
                                } removeAction: {
                                    checkListViewModel.deleteTag(
                                        tagId: tag.id)
                                    { result in
                                        switch result {
                                        case .success:
                                            break
                                        case .failure(let error):
                                            print("[Debug] \(error) \(#fileID) \(#function)")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 18)
                        .padding(.leading, 44)
                        .padding(.trailing, 30)
                        .padding(.bottom)
                    }
                }
                .frame(width: width, height: height * 0.86)
                .background(Color(0xFDFDFD))

                Spacer(minLength: 0)
            }
        }
        .frame(width: width, height: height)
        .background(
            RadialGradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF)], center: .center, startRadius: 0, endRadius: 350)
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
    var tag: Tag
    var tapAction: () -> Void
    var removeAction: () -> Void

    var body: some View {
        HStack {
            TagView(
                tag: tag,
                isSelected: false,
                disabled: !(tag.isSelected ?? false)
            )
            .onTapGesture {
                tapAction()
            }

            Spacer()

            Menu {
                Button {
                    removeAction()
                } label: {
                    Label("삭제", systemImage: "trash")
                        .foregroundColor(Color(0xF71E58))
                }
            } label: {
                Image("ellipsis")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x646464))
                    .frame(width: 28, height: 28)
            }
        }
    }
}

extension TagOptionView {
    func onChangeTag(_: String) {
        let trimTag = checkListViewModel.tagContent.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty
            && checkListViewModel.tagContent[
                checkListViewModel.tagContent.index(checkListViewModel.tagContent.endIndex, offsetBy: -1)
            ] == " "
        {
            if checkListViewModel.tagList.filter({ $0.content == trimTag }).isEmpty {
                checkListViewModel.addTag(
                    content: trimTag
                ) { result in
                    switch result {
                    case .success:
                        checkListViewModel.tagContent = ""
                    case .failure(let error):
                        print("[Debug] \(error) \(#fileID), \(#function)")
                    }
                }
            }
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
                        checkListViewModel.tagContent = ""
                    case .failure(let error):
                        print("[Debug] \(error) \(#fileID), \(#function)")
                    }
                }
            }
        }
    }
}
