//
//  MediaFeedView.swift
//  Haru
//
//  Created by 이준호 on 2023/06/14.
//

import SwiftUI

struct MediaFeedView: View {
    @Environment(\.dismiss) var dismissAction

    var post: Post
    var postImageUrlList: [URL?]
    @StateObject var postVM: PostViewModel

    @State var postOptModalVis: (Bool, Post?) = (false, nil)

    @State var deletePost: Bool = false
    @State var hidePost: Bool = false
    @State var reportPost: Bool = false

    var body: some View {
        ZStack {
            VStack {
                FeedView(
                    post: post,
                    postImageUrlList: postImageUrlList,
                    postVM: postVM,
                    postOptModalVis: $postOptModalVis
                )
                Spacer()
            }
            .padding(.top, 20)

            if self.postOptModalVis.0 {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.postOptModalVis.0 = false
                        }
                    }

                Modal(isActive: self.$postOptModalVis.0,
                      ratio: UIScreen.main.bounds.height < 800 ? 0.25 : 0.1)
                {
                    VStack(spacing: 20) {
                        if self.postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {} label: {
                                Text("이 게시글 수정하기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        } else {
                            Button {
                                withAnimation {
                                    self.hidePost = true
                                }
                            } label: {
                                Text("이 게시글 숨기기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                            .confirmationDialog(
                                "\(self.postOptModalVis.1?.user.name ?? "unknown")님의 게시글을 숨길까요? 이 작업은 복원할 수 없습니다.",
                                isPresented: self.$hidePost,
                                titleVisibility: .visible
                            ) {
                                Button("숨기기", role: .destructive) {
                                    self.postVM.hidePost(postId: self.postOptModalVis.1?.id ?? "unknown") { result in
                                        switch result {
                                        case .success:
                                            withAnimation {
                                                self.postVM.disablePost(
                                                    targetPost: self.postOptModalVis.1
                                                )
                                                dismissAction.callAsFunction()
                                                self.postOptModalVis.0 = false
                                            }
                                        case let .failure(failure):
                                            print("[Debug] \(failure) \(#file) \(#function)")
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                        if self.postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {
                                withAnimation {
                                    self.deletePost = true
                                }
                            } label: {
                                HStack {
                                    Text("게시글 삭제하기")
                                        .foregroundColor(Color(0xf71e58))
                                        .font(.pretendard(size: 20, weight: .regular))

                                    Image("sns-feed-delete-button")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color(0xf71e58))
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .confirmationDialog(
                                "게시글을 삭제할까요? 이 작업은 복원할 수 없습니다.",
                                isPresented: self.$deletePost,
                                titleVisibility: .visible
                            ) {
                                Button("삭제하기", role: .destructive) {
                                    self.postVM.deletePost(postId: self.postOptModalVis.1?.id ?? "unknown") { result in
                                        switch result {
                                        case .success:
                                            withAnimation {
                                                self.postVM.disablePost(
                                                    targetPost: self.postOptModalVis.1
                                                )
                                                dismissAction.callAsFunction()
                                                self.postOptModalVis.0 = false
                                            }
                                        case let .failure(failure):
                                            print("[Debug] \(failure) \(#file) \(#function)")
                                        }
                                    }
                                }
                            }
                        } else {
                            Button {
                                self.reportPost = true
                            } label: {
                                Text("이 게시글 신고하기")
                                    .foregroundColor(Color(0xf71e58))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                            .confirmationDialog(
                                "게시글을 신고할까요?",
                                isPresented: self.$reportPost,
                                titleVisibility: .visible
                            ) {
                                Button("신고하기", role: .destructive) {
                                    self.postVM.reportPost(postId: self.postOptModalVis.1?.id ?? "unknown") { result in
                                        switch result {
                                        case .success:
                                            withAnimation {
                                                self.postVM.disablePost(
                                                    targetPost: self.postOptModalVis.1
                                                )
                                                dismissAction.callAsFunction()
                                                self.postOptModalVis.0 = false
                                            }
                                            // TODO: 토스트 메시지로 신고가 접수 되었다고 알리기
                                            print("신고가 잘 접수 되었습니다.")
                                        case let .failure(failure):
                                            print("[Debug] \(failure) \(#file) \(#function)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 40)
                }
                .opacity(self.deletePost || self.hidePost || self.reportPost ? 0 : 1)
                .transition(.modal)
                .zIndex(2)
            }
        }
        .background(Color(0xfdfdfd))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                }
            }
        }
    }
}
