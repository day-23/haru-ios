//
//  TagDetailView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/19.
//

import SwiftUI

struct TagDetailView: View {
    @Environment(\.dismiss) var dismissAction

    private let tagId: String
    private let originalContent: String
    private let originalOnAlarm: Bool
    private let originalIsSelected: Bool

    @StateObject var checkListViewModel: CheckListViewModel
    @State private var content: String
    @State private var onAlarm: Bool
    @State private var isSelected: Bool
    @State private var count: Int = 0

    @State private var backButtonTapped: Bool = false
    @State private var confirmButtonTapped: Bool = false
    @State private var deleteButtonTapped: Bool = false

    private var noChanges: Bool {
        return originalContent == content
            && originalOnAlarm == onAlarm
            && originalIsSelected == isSelected
    }

    init(
        checkListViewModel: StateObject<CheckListViewModel>,
        tagId: String,
        content: String,
        onAlarm: Bool,
        isSelected: Bool
    ) {
        self.tagId = tagId
        originalContent = content
        originalOnAlarm = onAlarm
        originalIsSelected = isSelected

        _checkListViewModel = checkListViewModel
        _content = .init(initialValue: content)
        _onAlarm = .init(initialValue: onAlarm)
        _isSelected = .init(initialValue: isSelected)
    }

    var body: some View {
        VStack(spacing: 14) {
            TextField("", text: $content)
                .font(.pretendard(size: 24, weight: .bold))
                .foregroundColor(Color(0x191919))
                .padding(.top, 10)
                .padding(.leading, 34)
                .padding(.trailing, 20)

            Divider()

            HStack(spacing: 0) {
                Text("연관된 할 일")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(Color(0x191919))

                Spacer()

                Text("\(count)개")
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundColor(Color(0x191919))
            }
            .padding(.leading, 34)
            .padding(.trailing, 20)

            Divider()

            Toggle(isOn: $isSelected.animation()) {
                HStack {
                    Text("상단에 태그 띄우기")
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x191919))

                    Spacer()
                }
            }
            .toggleStyle(CustomToggleStyle())
            .padding(.leading, 34)
            .padding(.trailing, 20)

            Spacer()

            Button {
                deleteButtonTapped = true
            } label: {
                HStack(spacing: 10) {
                    Text("태그 삭제")
                        .font(.pretendard(size: 20, weight: .regular))
                    Image("todo-delete")
                        .renderingMode(.template)
                }
                .foregroundColor(Color(0xf71e58))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
        }
        .confirmationDialog("태그를 삭제할까요?", isPresented: $deleteButtonTapped, titleVisibility: .visible) {
            Button("삭제하기", role: .destructive) {
                TagService.deleteTag(tagId: tagId) { result in
                    switch result {
                    case .success:
                        dismissAction.callAsFunction()
                    case .failure:
                        break
                    }
                }
            }
        }
        .confirmationDialog(
            "현재 화면에서 나갈까요? 수정사항이 있습니다.",
            isPresented: $backButtonTapped,
            titleVisibility: .visible
        ) {
            Button("나가기", role: .destructive) {
                dismissAction.callAsFunction()
            }
        }
        .confirmationDialog(
            "수정사항을 저장할까요?",
            isPresented: $confirmButtonTapped,
            titleVisibility: .visible
        ) {
            Button("저장하기") {
                if !noChanges {
                    checkListViewModel.updateTag(
                        tagId: tagId,
                        params: [
                            "content": content,
                            "isSelected": isSelected
                        ]
                    ) { response in
                        switch response {
                        case .success:
                            dismissAction.callAsFunction()
                        case .failure:
                            break
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if noChanges {
                        dismissAction.callAsFunction()
                    } else {
                        backButtonTapped = true
                    }
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("태그 수정")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    confirmButtonTapped = true
                } label: {
                    Image("confirm")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }
        }
        .onAppear {
            TagService.fetchTodoCountByTag(tagId: tagId) { result in
                switch result {
                case .success(let data):
                    count = data
                case .failure:
                    break
                }
            }
        }
        .padding(.top, 15)
    }
}
