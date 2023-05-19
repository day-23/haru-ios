//
//  PostFormPreView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/11.
//

import SwiftUI

struct PostFormPreView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var postFormVM: PostFormViewModel

    @FocusState private var tagInFocus: Bool

    // For pop up to root
    @Binding var shouldPopToRootView: Bool

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        VStack(alignment: .leading, spacing: 0) {
            Group {
                Label {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(
                                Array(zip(postFormVM.tagList.indices, postFormVM.tagList)),
                                id: \.0
                            ) { index, tag in
                                TagView(tag: Tag(id: tag.id, content: tag.content))
                                    .onTapGesture {
                                        postFormVM.tagList.remove(at: index)
                                    }
                            }

                            TextField("태그 추가", text: $postFormVM.tag)
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(postFormVM.tagList.isEmpty ? Color(0xacacac) : .black)
                                .onChange(
                                    of: postFormVM.tag,
                                    perform: onChangeTag
                                )
                                .onSubmit(onSubmitTag)
                                .focused($tagInFocus)
                        }
                        .padding(1)
                    }
                    .onTapGesture {
                        tagInFocus = true
                    }
                } icon: {
                    Image(systemName: "tag")
                        .frame(width: 28, height: 28)
                        .padding(.trailing, 10)
                        .foregroundColor(postFormVM.tagList.isEmpty ? Color(0xacacac) : .black)
                }
                .padding(.horizontal, 20)
            }

            Spacer()
                .frame(height: 65)

            if !postFormVM.imageList.isEmpty {
                TabView {
                    ForEach(postFormVM.imageList.indices, id: \.self) { idx in
                        Image(uiImage: postFormVM.imageList[idx])
                            .resizable()
                            .scaledToFill()
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(width: deviceSize.width, height: deviceSize.width)
            } else {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Gradient(colors: [.gradientStart2, .gradientEnd2]))
                        .frame(width: deviceSize.width, height: deviceSize.width)

                    Text(postFormVM.content)
                        .lineLimit(nil)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.all, 20)
                }
            }

            Spacer()
                .frame(height: 20)

            if !postFormVM.imageList.isEmpty {
                Text(postFormVM.content)
                    .lineLimit(nil)
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(Color(0x646464))
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 12)
        .customNavigationBar {
            Button {
                dismissAction.callAsFunction()
            } label: {
                Image("cancel")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x191919))
            }
        } rightView: {
            HStack(spacing: 10) {
                Button {
                    postFormVM.createPost {
                        shouldPopToRootView = false
                    }
                } label: {
                    Text("게시하기")
                        .font(.pretendard(size: 20, weight: .bold))
                }
                Image("confirm")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x191919))
            }
        }
    }

    func onChangeTag(_: String) {
        let trimTag = postFormVM.tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty, postFormVM.tag[postFormVM.tag.index(postFormVM.tag.endIndex, offsetBy: -1)] == " " {
            if postFormVM.tagList.filter({ $0.content == trimTag }).isEmpty {
                postFormVM.tagList.append(Tag(id: UUID().uuidString, content: trimTag))
                postFormVM.tag = ""
            }
        }
    }

    func onSubmitTag() {
        let trimTag = postFormVM.tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty {
            if postFormVM.tagList.filter({ $0.content == trimTag }).isEmpty {
                postFormVM.tagList.append(Tag(id: UUID().uuidString, content: trimTag))
                postFormVM.tag = ""
            }
        }
    }
}
