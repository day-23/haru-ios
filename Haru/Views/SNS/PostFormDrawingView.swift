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
            TextField("텍스트를 입력해주세요.", text: $postFormVM.content, axis: .vertical)
                .lineLimit(nil)
                .frame(alignment: .top)
                .font(.pretendard(size: 24, weight: .regular))
                .background(Color(0xfdfdfd))
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
        }
        .background(Color(0xfdfdfd))
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .rotationEffect(Angle(degrees: 180))
                        .foregroundColor(Color(0x191919))
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
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
                .disabled(postFormVM.content == "")
            }
        }
    }
}
