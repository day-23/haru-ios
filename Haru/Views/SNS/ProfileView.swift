//
//  ProfileView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/24.
//

import ScalingHeaderScrollView
import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismissAction

    @State private var isFeedSelected: Bool = true

    @StateObject var postVM: PostViewModel
    @StateObject var userProfileVM: UserProfileViewModel

    @State var postOptModalVis: (Bool, Post?) = (false, nil)
    @State var blockModalVis: Bool = false

    @State var blockFriend: Bool = false

    @State var deletePost: Bool = false
    @State var hidePost: Bool = false
    @State var reportPost: Bool = false

    var myProfile: Bool = false

    @State var scrollToTop: () -> Void = {}

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Image("back-button")
                            .frame(width: 28, height: 28)
                    }

                    Spacer()

                    if !userProfileVM.isMe {
                        Button {
                            withAnimation {
                                blockModalVis = true
                            }
                        } label: {
                            Image("more")
                        }
                    } else {
                        HStack(spacing: 5) {
                            Image("sns-my-history")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 28, height: 28)

                            Text("내 기록")
                                .font(.pretendard(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color(0x1DAFFF))
                        .padding(.trailing, 8)
                    }
                }
                .frame(height: 48)
                .padding(.horizontal, 20)
                .background(.white)

                ScalingHeaderScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ProfileInfoView(userProfileVM: userProfileVM)
                                .background(Color.white)
                                .padding(.top, 20)

                            Spacer()
                                .frame(height: 23)
                        }

                        headerView()

                        Spacer()
                    }
                    .frame(height: 210)
                } content: {
                    if userProfileVM.isPublic {
                        if self.isFeedSelected {
                            FeedListView(postVM: self.postVM, postOptModalVis: self.$postOptModalVis)
                                .background(Color.white)
                                .animation(.none, value: UUID().uuidString)
                        } else {
                            MediaListView(postVM: self.postVM, scrollable: false)
                                .background(Color.white)
                                .animation(.none, value: UUID().uuidString)
                        }
                    } else {
                        VStack(spacing: 0) {
                            Image("sns-private-background")
                                .resizable()
                                .frame(width: 160, height: 190)
                                .padding(.top, 68)
                                .padding(.bottom, 55)
                            Text("비공개 계정입니다.")
                                .padding(.bottom, 5)
                            Text("수락된 친구만 게시글을 볼 수 있어요.")
                            Spacer()
                        }
                    }
                }
                .height(min: 40, max: 210)
                .hideScrollIndicators()
                .background(Color.white)
                .clipped()
                .introspectScrollView { controller in
                    DispatchQueue.main.async {
                        scrollToTop = {
                            controller.setContentOffset(.zero, animated: true)
                        }
                    }
                }
                .onChange(of: isFeedSelected) { _ in
                    scrollToTop()
                }
            }

            if postOptModalVis.0 {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.postOptModalVis.0 = false
                        }
                    }

                Modal(isActive: self.$postOptModalVis.0,
                      ratio: 0.2)
                {
                    VStack(spacing: 20) {
                        Spacer()

                        if self.postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {} label: {
                                Text("이 게시글 수정하기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }

                            Divider()
                        }

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

                                    Image("sns-feed-delete-button")
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
                                            withAnimation {
                                                self.postVM.disablePost(
                                                    targetPost: self.postOptModalVis.1
                                                )
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
                                            withAnimation {
                                                self.postVM.disablePost(
                                                    targetPost: self.postOptModalVis.1
                                                )
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

                            Divider()

                            Button {
                                withAnimation {
                                    self.postOptModalVis.0 = false
                                }
                            } label: {
                                Text("취소하기")
                                    .foregroundColor(Color(0x1DAFFF))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        }

                        Spacer()
                    }
                }
                .opacity(self.deletePost || self.hidePost || self.reportPost ? 0 : 1)
                .transition(.modal)
                .zIndex(2)
            } else if blockModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.blockModalVis = false
                        }
                    }

                Modal(isActive: self.$blockModalVis,
                      ratio: UIScreen.main.bounds.height < 800 ? 0.4 : 0.3)
                {
                    VStack(spacing: 0) {
                        ProfileImgView(profileImage: userProfileVM.profileImage)
                            .frame(width: 70, height: 70)
                            .padding(.bottom, 12)

                        Text("\(userProfileVM.user.name)")
                            .font(.pretendard(size: 20, weight: .bold))
                            .foregroundColor(Color(0x191919))

                        Divider()
                            .padding(.top, 34)
                            .padding(.bottom, 20)

                        Button {
                            withAnimation {
                                blockFriend = true
                            }
                        } label: {
                            Text("이 이용자 차단하기")
                                .font(.pretendard(size: 20, weight: .regular))
                                .foregroundColor(Color(0xF71E58))
                        }.confirmationDialog(
                            "\(userProfileVM.user.name)님을 차단할까요? 차단된 이용자는 내 피드를 볼 수 없으며 나에게 친구 신청을 보낼 수 없습니다. 차단된 이용자에게는 내 계정이 검색되지 않습니다.",
                            isPresented: $blockFriend,
                            titleVisibility: .visible
                        ) {
                            Button("차단하기", role: .destructive) {
                                userProfileVM.blockedFriend(blockUserId: userProfileVM.user.id) { result in
                                    switch result {
                                    case let .success(success):
                                        if !success {
                                            print("Toast Message로 알려주기")
                                        }
                                        userProfileVM.fetchUserProfile()
                                    case let .failure(failure):
                                        print("\(failure) \(#file) \(#function)")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 25)
                }
                .opacity(self.blockFriend ? 0 : 1)
                .transition(.modal)
                .zIndex(2)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            self.userProfileVM.fetchUserProfile()
        }
        .onChange(of: reportPost) { _ in
            if reportPost == false {
                postOptModalVis.0 = false
            }
        }
        .onChange(of: deletePost) { _ in
            if deletePost == false {
                postOptModalVis.0 = false
            }
        }
    }

    @ViewBuilder
    func headerView() -> some View {
        if userProfileVM.isPublic {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(self.userProfileVM.isMe ? "내 피드" : "피드")
                        .frame(width: 175)
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(self.isFeedSelected ? Color(0x1DAFFF) : Color(0xACACAC))
                        .onTapGesture {
                            postVM.option = .targetFeed
                            withAnimation {
                                self.isFeedSelected = true
                            }
                        }

                    Text("미디어")
                        .frame(width: 175)
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(self.isFeedSelected ? Color(0xACACAC) : Color(0x1DAFFF))
                        .onTapGesture {
                            postVM.option = .targetMediaAll
                            withAnimation {
                                self.isFeedSelected = false
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .padding(.top, 10)
                .padding(.bottom, 10)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 175 * 2, height: 4)

                    Rectangle()
                        .fill(RadialGradient(
                            colors: [
                                Color(0xAAD7FF),
                                Color(0xD2D7FF)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        ))
                        .frame(width: 175, height: 4)
                        .offset(x: self.isFeedSelected ? 0 : 175)
                }
            }
            .background(Color.white)
        }
    }
}
