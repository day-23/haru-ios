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

    private var noChanges: Bool {
        return (originalContent == content
            && originalOnAlarm == onAlarm
            && originalIsSelected == isSelected)
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

            Toggle(isOn: $onAlarm.animation()) {
                HStack {
                    Text("할 일 알림")
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x191919))

                    Spacer()
                }
            }
            .toggleStyle(CustomToggleStyle())
            .padding(.leading, 34)
            .padding(.trailing, 20)

            Divider()

            HStack(spacing: 0) {
                Text("연관된 할 일")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(Color(0x191919))

                Spacer()

                Text("00개")
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

            Button {} label: {
                HStack(spacing: 10) {
                    Text("태그 삭제하기")
                        .font(.pretendard(size: 20, weight: .regular))
                    Image("trash")
                        .renderingMode(.template)
                }
                .foregroundColor(Color(0xf71e58))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    checkListViewModel.updateTag(
                        tagId: tagId,
                        params: [
                            "content": content,
                            "isSelected": isSelected
                        ]
                    ) { response in
                        switch response {
                        case .success(let success):
                            dismissAction.callAsFunction()
                        case .failure(let error):
                            print("[Debug] \(error) \(#fileID) \(#function)")
                        }
                    }
                } label: {
                    Image("confirm")
                        .renderingMode(.template)
                        .foregroundColor(noChanges ? Color(0xacacac) : Color(0x191919))
                }
                .disabled(noChanges)
            }
        }
    }
}