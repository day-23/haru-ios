//
//  PostFormDrawing.swift
//  Haru
//
//  Created by 이준호 on 2023/06/11.
//

import SwiftUI

struct PostFormDrawingView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var postFormVM: PostFormViewModel

    @Binding var rootIsActive: Bool
    @Binding var createPost: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            TextField("", text: $postFormVM.content, axis: .vertical)
                .placeholder(when: postFormVM.content.isEmpty, placeholder: {
                    Text("텍스트를 입력해주세요.")
                        .font(.pretendard(size: 24, weight: .regular))
                        .foregroundColor(Color(0xacacac))
                })
                .lineLimit(15)
                .frame(alignment: .top)
                .font(.pretendard(size: 24, weight: .bold))
                .foregroundColor(Color(0x191919))
                .background(Color(0xfdfdfd))
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .onChange(of: postFormVM.content) { value in
                    if value.count > 1000 {
                        postFormVM.content = String(
                            value[
                                value.startIndex ..< value.index(value.endIndex, offsetBy: -1)
                            ]
                        )
                    }
                }
        }
        .background(Color(0xfdfdfd))
        .onTapGesture {
            if isFocused {
                hideKeyboard()
            } else {
                isFocused = true
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x1dafff))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("하루 그리기")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    PostFormPreView(
                        postFormVM: postFormVM,
                        shouldPopToRootView: $rootIsActive,
                        createPost: $createPost
                    )

                } label: {
                    Image("back-button")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x1dafff))
                        .rotationEffect(Angle(degrees: 180))
                }
            }
        }
    }
}
