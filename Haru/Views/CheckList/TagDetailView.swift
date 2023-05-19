//
//  TagDetailView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/19.
//

import SwiftUI

struct TagDetailView: View {
    @Environment(\.dismiss) var dismissAction

    var tag: Tag
    @State private var title: String = ""
    @State private var onAlarm: Bool = false
    @State private var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 14) {
            TextField("", text: $title)
                .font(.pretendard(size: 24, weight: .bold))
                .foregroundColor(Color(0x191919))
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
                Button {} label: {
                    Image("confirm")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }
        }
        .onAppear {
            title = tag.content
        }
    }
}
