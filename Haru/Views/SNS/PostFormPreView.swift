//
//  PostFormPreView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/11.
//

import SwiftUI
import UIKit

struct PostFormPreView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var postFormVM: PostFormViewModel

    @FocusState private var tagInFocus: Bool

    // For pop up to root
    @Binding var shouldPopToRootView: Bool

    @State var selectedTemplateIdx: Int = 0
    @State var blackSelected: Bool = true

    @State var ratio: Double = 0.35
    @State var isModalUp: Bool = true

    @State var waitingResponse: Bool = false

    let deviceSize = UIScreen.main.bounds.size
    var body: some View {
        VStack(spacing: 0) {
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

            if postFormVM.postOption == .drawing {
                TabView {
                    ForEach(postFormVM.imageList.indices, id: \.self) { idx in
                        Image(uiImage: postFormVM.imageList[idx])
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.height
                            )
                            .clipped()
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(width: deviceSize.width, height: deviceSize.width)
            } else {
                ZStack {
                    if postFormVM.templateList.isEmpty {
                        Rectangle()
                            .fill(Color(0xfdfdfd))
                            .frame(width: deviceSize.width, height: deviceSize.width)
                    } else {
                        if let uiImage = postFormVM.templateList[selectedTemplateIdx]?.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: deviceSize.width, height: deviceSize.width)
                        } else {
                            ProgressView()
                                .frame(width: deviceSize.width, height: deviceSize.width)
                        }
                    }

                    Text(postFormVM.content)
                        .lineLimit(nil)
                        .font(.pretendard(size: 24, weight: .bold))
                        .foregroundColor(blackSelected ? Color(0x191919) : Color(0xfdfdfd))
                        .padding(.all, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if postFormVM.postOption == .drawing {
                Text(postFormVM.content)
                    .lineLimit(nil)
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(Color(0x646464))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                Spacer()
            } else {
                Spacer()
                    .overlay(alignment: .bottom) {
                        bottomTemplateView()
                    }
            }
        }
        .padding(.top, tagInFocus ? 80 : 20)
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("cancel")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("게시하기")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    waitingResponse = true
                    switch postFormVM.postOption {
                    case .drawing:
                        postFormVM.createPost { result in
                            switch result {
                            case .success:
                                shouldPopToRootView = false
                            case .failure(let failure):
                                waitingResponse = false
                                print("[Debug] \(failure) \(#fileID) \(#function)")
                            }
                        }
                    case .writing:
                        postFormVM.createPost(templateIdx: selectedTemplateIdx) { result in
                            switch result {
                            case .success:
                                shouldPopToRootView = false
                            case .failure(let failure):
                                waitingResponse = false
                                print("[Debug] \(failure) \(#fileID) \(#function)")
                            }
                        }
                    }
                } label: {
                    Image("confirm")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
                .disabled(waitingResponse)
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

    @ViewBuilder
    func bottomTemplateView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Group {
                    Text("템플릿")
                        .font(.pretendard(size: 20, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    Image("toggle")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .onTapGesture {
                    withAnimation {
                        if isModalUp {
                            ratio = 0.1
                        } else {
                            ratio = 0.35
                        }

                        isModalUp.toggle()
                    }
                }

                Spacer()
            }
            .clipped()
            .padding(.top, 27)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            if ratio == 0.35 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(postFormVM.templateIdList.indices, id: \.self) { idx in
                            ZStack(alignment: .topTrailing) {
                                if let uiImage = postFormVM.templateList[idx]?.uiImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 74, height: 74)
                                        .onTapGesture {
                                            selectedTemplateIdx = idx
                                        }
                                } else {
                                    ProgressView()
                                        .frame(width: 74, height: 74)
                                }

                                Group {
                                    Circle()
                                        .fill(idx == selectedTemplateIdx ? .blue : .white.opacity(0.25))

                                    Circle()
                                        .stroke(.white, lineWidth: 1)
                                }
                                .frame(width: 20, height: 20)
                                .padding(.all, 4)
                            }
                            .clipped()
                        }
                    }
                }
                .padding(.horizontal, 20)

                HStack(spacing: 10) {
                    Image("today-todo")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .background(Color(0x191919))
                        .cornerRadius(8)
                        .foregroundColor(blackSelected ? Color(0x1dafff) : Color(0xfdfdfd))
                        .overlay {
                            if blackSelected {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color(0x1dafff),
                                        lineWidth: 2
                                    )
                            }
                        }
                        .onTapGesture {
                            blackSelected = true
                            postFormVM.templateTextColor = "#191919"
                        }

                    Image("today-todo")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .background(Color(0xfdfdfd))
                        .cornerRadius(8)
                        .foregroundColor(Color(0x191919))
                        .overlay {
                            if !blackSelected {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color(0x1dafff),
                                        lineWidth: 2
                                    )
                            }
                        }
                        .onTapGesture {
                            blackSelected = false
                            postFormVM.templateTextColor = "#FDFDFD"
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)

                Spacer()
            }
        }
        .frame(width: deviceSize.width, height: deviceSize.height * ratio)
        .background {
            Image("bg-gradation-calendar")
                .resizable()
                .frame(width: deviceSize.width, height: deviceSize.height * ratio)
        }
        .cornerRadius(30)
        .shadow(radius: 50)
    }
}
