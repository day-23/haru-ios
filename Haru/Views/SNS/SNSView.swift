//
//  SNSView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct SNSView: View {
    @StateObject var postVM = PostViewModel(option: .main)

    @State var toggleIsClicked: Bool = false

    // For pop up to root
    @State var isActiveForDrawing: Bool = false
    @State var isActiveForWriting: Bool = false

    @State var postOptModalVis: (Bool, Post?) = (false, nil)

    @State var showDrowButton: Bool = false
    @State var showWriteButton: Bool = false
    @State var showAddButton: Bool = true

    @State var deletePost: Bool = false
    @State var hidePost: Bool = false
    @State var reportPost: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                self.HaruHeaderView()

                FeedListView(postVM: self.postVM, postOptModalVis: self.$postOptModalVis, comeToRoot: true)
            }

            if self.toggleIsClicked {
                DropdownMenu {
                    Text("친구피드")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x1DAFFF))
                } secondContent: {
                    NavigationLink {
                        LookAroundView()
                    } label: {
                        Text("둘러보기")
                            .font(.pretendard(size: 16, weight: .bold))
                    }
                }
            }

            if self.postOptModalVis.0 {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.postOptModalVis.0 = false
                        }
                    }

                Modal(isActive: self.$postOptModalVis.0, ratio: 0.1) {
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
                                            self.postVM.refreshPosts()
                                            self.postOptModalVis.0 = false
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
                                        .foregroundColor(Color(0xF71E58))
                                        .font(.pretendard(size: 20, weight: .regular))

                                    Image("trash")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color(0xF71E58))
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
                                            self.postVM.refreshPosts()
                                            self.postOptModalVis.0 = false
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
                                    .foregroundColor(Color(0xF71E58))
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
                                            self.postVM.refreshPosts()
                                            self.postOptModalVis.0 = false
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

            if !self.postOptModalVis.0 {
                VStack {
                    if self.showDrowButton {
                        NavigationLink(
                            destination: PostFormView(
                                postFormVM: PostFormViewModel(postOption: .drawing),
                                openPhoto: true,
                                rootIsActive: self.$isActiveForDrawing,
                                postAddMode: .drawing
                            ),
                            isActive: self.$isActiveForDrawing
                        ) {
                            Image("sns-haru-draw-button")
                                .shadow(radius: 10, x: 5, y: 0)
                        }
                    }

                    if self.showWriteButton {
                        NavigationLink(
                            destination: PostFormView(
                                postFormVM: PostFormViewModel(postOption: .writing),
                                openPhoto: false,
                                rootIsActive: self.$isActiveForWriting,
                                postAddMode: .writing
                            ),
                            isActive: self.$isActiveForWriting
                        ) {
                            Image("sns-haru-write-button")
                                .shadow(radius: 10, x: 5, y: 0)
                        }
                    }

                    if self.showAddButton {
                        Button {
                            withAnimation {
                                self.showAddMenu()
                            }
                        } label: {
                            Image("add-button")
                        }
                    }
                }
                .zIndex(5)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .onTapGesture {
            withAnimation {
                self.hideAddMenu()
            }
        }
        .onAppear {
            self.toggleIsClicked = false
        }
        .onChange(of: self.isActiveForDrawing) { _ in
            self.postVM.refreshPosts()
        }
        .onChange(of: self.isActiveForWriting) { _ in
            self.postVM.refreshPosts()
        }
    }

    func showAddMenu() {
        self.showAddButton = false
        self.showWriteButton = true
        self.showDrowButton = true
    }

    func hideAddMenu() {
        self.showDrowButton = false
        self.showWriteButton = false
        self.showAddButton = true
    }

    @ViewBuilder
    func HaruHeaderView() -> some View {
        HaruHeader(toggleIsClicked: self.$toggleIsClicked) {
            HStack(spacing: 10) {
                NavigationLink {
                    ProfileView(
                        postVM: PostViewModel(targetId: Global.shared.user?.id ?? nil, option: .target_feed),
                        userProfileVM: UserProfileViewModel(userId: Global.shared.user?.id ?? "unknown"),
                        myProfile: true
                    )
                } label: {
                    Text("내 기록")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            LinearGradient(colors: [Color(0xFDFDFD)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )

                        })
                        .padding(.vertical, 1)
                }

                NavigationLink {
                    // TODO: 검색 뷰 만들어지면 넣어주기
                    Text("검색")
                } label: {
                    Image("search")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(Color(0x191919))
                        .frame(width: 28, height: 28)
                }
            }
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
