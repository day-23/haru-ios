//
//  PostFormPreView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/11.
//

import SwiftUI

struct PostFormPreView: View {
    @Environment(\.dismiss) var dismissAction

    @FocusState private var tagInFocus: Bool

    @State var tag: String = ""
    @State var tagList: [Tag] = []

    var images: [UIImage]
    var content: String

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        VStack(alignment: .leading, spacing: 0) {
            Group {
                Label {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(
                                Array(zip(tagList.indices, tagList)),
                                id: \.0
                            ) { index, tag in
                                TagView(tag: Tag(id: tag.id, content: tag.content))
                                    .onTapGesture {
                                        tagList.remove(at: index)
                                    }
                            }

                            TextField("태그 추가", text: $tag)
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(tagList.isEmpty ? Color(0xacacac) : .black)
                                .onChange(
                                    of: tag,
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
                        .foregroundColor(tagList.isEmpty ? Color(0xacacac) : .black)
                }
                .padding(.horizontal, 20)
            }

            Spacer()
                .frame(height: 65)

            if !images.isEmpty {
                TabView {
                    ForEach(images.indices, id: \.self) { idx in
                        Image(uiImage: images[idx])
                            .resizable()
                            .scaledToFill()
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(width: deviceSize.width, height: deviceSize.width)
            } else {
                Rectangle()
                    .fill(Gradient(colors: [.gradientStart2, .gradientEnd2]))
                    .frame(width: deviceSize.width, height: deviceSize.width)
            }

            Spacer()
                .frame(height: 20)

            Text(content)
                .lineLimit(nil)
                .font(.pretendard(size: 14, weight: .regular))
                .foregroundColor(Color(0x646464))
                .padding(.horizontal, 20)
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
                Text("게시하기")
                    .font(.pretendard(size: 20, weight: .bold))
                Image("confirm")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x191919))
            }
        }
    }

    func onChangeTag(_: String) {
        let trimTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty, tag[tag.index(tag.endIndex, offsetBy: -1)] == " " {
            if tagList.filter({ $0.content == trimTag }).isEmpty {
                tagList.append(Tag(id: UUID().uuidString, content: trimTag))
                tag = ""
            }
        }
    }

    func onSubmitTag() {
        let trimTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty {
            if tagList.filter({ $0.content == trimTag }).isEmpty {
                tagList.append(Tag(id: UUID().uuidString, content: trimTag))
                tag = ""
            }
        }
    }
}

// struct PostFormPreView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFormPreView(content: "학교 가기 싫음")
//    }
// }
