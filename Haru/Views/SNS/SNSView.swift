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
                HaruHeaderView()

                FeedListView(postVM: postVM, postOptModalVis: $postOptModalVis, comeToRoot: true)
            }

            if toggleIsClicked {
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

            if postOptModalVis.0 {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            postOptModalVis.0 = false
                        }
                    }

                Modal(isActive: $postOptModalVis.0, ratio: 0.1) {
                    VStack(spacing: 20) {
                        if postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {} label: {
                                Text("이 게시글 수정하기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        } else {
                            Button {
                                withAnimation {
                                    hidePost = true
                                }
                            } label: {
                                Text("이 게시글 숨기기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                            .confirmationDialog(
                                "\(postOptModalVis.1?.user.name ?? "unknown")님의 게시글을 숨길까요? 이 작업은 복원할 수 없습니다.",
                                isPresented: $hidePost,
                                titleVisibility: .visible
                            ) {
                                Button("숨기기", role: .destructive) {
                                    postVM.hidePost(postId: postOptModalVis.1?.id ?? "unknown") { result in
                                        switch result {
                                        case .success:
                                            postVM.refreshPosts()
                                            postOptModalVis.0 = false
                                        case .failure(let failure):
                                            print("[Debug] \(failure) \(#file) \(#function)")
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                        if postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {
                                withAnimation {
                                    deletePost = true
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
                                isPresented: $deletePost,
                                titleVisibility: .visible
                            ) {
                                Button("삭제하기", role: .destructive) {
                                    postVM.deletePost(postId: postOptModalVis.1?.id ?? "unknown") { result in
                                        switch result {
                                        case .success:
                                            postVM.refreshPosts()
                                            postOptModalVis.0 = false
                                        case .failure(let failure):
                                            print("[Debug] \(failure) \(#file) \(#function)")
                                        }
                                    }
                                }
                            }
                        } else {
                            Button {
                                reportPost = true
                            } label: {
                                Text("이 게시글 신고하기")
                                    .foregroundColor(Color(0xF71E58))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                            .confirmationDialog(
                                "게시글을 신고할까요?",
                                isPresented: $reportPost,
                                titleVisibility: .visible
                            ) {
                                Button("신고하기", role: .destructive) {
                                    postVM.reportPost(postId: postOptModalVis.1?.id ?? "unknown") { result in
                                        switch result {
                                        case .success:
                                            postVM.refreshPosts()
                                            postOptModalVis.0 = false
                                            // TODO: 토스트 메시지로 신고가 접수 되었다고 알리기
                                            print("신고가 잘 접수 되었습니다.")
                                        case .failure(let failure):
                                            print("[Debug] \(failure) \(#file) \(#function)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 40)
                }
                .opacity(deletePost || hidePost || reportPost ? 0 : 1)
                .transition(.modal)
                .zIndex(2)
            }

            if !postOptModalVis.0 {
                VStack {
                    if showDrowButton {
                        NavigationLink(
                            destination: PostFormView(
                                postFormVM: PostFormViewModel(postOption: .drawing),
                                openPhoto: true,
                                rootIsActive: $isActiveForDrawing,
                                postAddMode: .drawing
                            ),
                            isActive: $isActiveForDrawing
                        ) {
                            Image("sns-drawing-button")
                                .shadow(radius: 10, x: 5, y: 0)
                        }
                    }

                    if showWriteButton {
                        NavigationLink(
                            destination: PostFormView(
                                postFormVM: PostFormViewModel(postOption: .writing),
                                openPhoto: false,
                                rootIsActive: $isActiveForWriting,
                                postAddMode: .writing
                            ),
                            isActive: $isActiveForWriting
                        ) {
                            Image("sns-write-button")
                                .shadow(radius: 10, x: 5, y: 0)
                        }
                    }

                    if showAddButton {
                        Button {
                            withAnimation {
                                showAddMenu()
                            }
                        } label: {
                            Image("sns-add-button")
                                .shadow(radius: 10, x: 5, y: 0)
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
                hideAddMenu()
            }
        }
        .onAppear {
            toggleIsClicked = false
        }
        .onChange(of: isActiveForDrawing) { _ in
            postVM.refreshPosts()
        }
        .onChange(of: isActiveForWriting) { _ in
            postVM.refreshPosts()
        }
    }

    func showAddMenu() {
        showAddButton = false
        showWriteButton = true
        showDrowButton = true
    }

    func hideAddMenu() {
        showDrowButton = false
        showWriteButton = false
        showAddButton = true
    }

    @ViewBuilder
    func HaruHeaderView() -> some View {
        HaruHeader(toggleIsClicked: $toggleIsClicked) {
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
                    Image("magnifyingglass")
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
