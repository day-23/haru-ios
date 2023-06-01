//
//  SNSView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct SNSView: View {
    @State var toggleIsClicked: Bool = false

    // For pop up to root
    @State var isActive: Bool = false

    @State var postOptModalVis: (Bool, Post?) = (false, nil)

    @State var showDrowButton: Bool = false
    @State var showWriteButton: Bool = false
    @State var showAddButton: Bool = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HaruHeaderView()

                FeedListView(postVM: PostViewModel(option: .main), postOptModalVis: $postOptModalVis, comeToRoot: true)
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
                            Button {} label: {
                                Text("이 게시글 숨기기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        }
                        Divider()
                        if postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {} label: {
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
                        } else {
                            Button {} label: {
                                Text("이 게시글 신고하기")
                                    .foregroundColor(Color(0xF71E58))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        }
                    }
                    .padding(.top, 40)
                }
                .transition(.modal)
                .zIndex(2)
            }

            if !postOptModalVis.0 {
                VStack {
                    if showDrowButton {
                        NavigationLink(
                            destination: PostFormView(rootIsActive: $isActive),
                            isActive: $isActive
                        ) {
                            Image("sns-write-button")
                                .shadow(radius: 10, x: 5, y: 0)
                        }
                    }

                    if showWriteButton {
                        NavigationLink(
                            destination: PostFormView(rootIsActive: $isActive),
                            isActive: $isActive
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
                            //                                            ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
