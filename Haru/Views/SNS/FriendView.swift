//
//  FallowView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FriendView: View {
    // MARK: Internal

    @Environment(\.dismiss) var dismissAction

    @StateObject var userProfileVM: UserProfileViewModel

    @State var friendTab: Bool = true
    @State var searchWord: String = ""

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                VStack(spacing: 0) {
                    if self.userProfileVM.isMe {
                        HStack(spacing: 0) {
                            Text("친구 목록 \(self.userProfileVM.friendCount)")
                                .frame(width: 175, height: 20)
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(self.friendTab ? Color(0x1DAFFF) : Color(0xACACAC))
                                .onTapGesture {
                                    self.userProfileVM.option = .friendList
                                    withAnimation {
                                        self.friendTab = true
                                    }
                                }

                            Text("친구 신청 \(self.userProfileVM.reqFriendCount)")
                                .frame(width: 175, height: 20)
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(self.friendTab ? Color(0xACACAC) : Color(0x1DAFFF))
                                .onTapGesture {
                                    self.userProfileVM.option = .requestFriendList
                                    withAnimation {
                                        self.friendTab = false
                                    }
                                }
                        }
                        .padding(.bottom, 10)

                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 175 * 2, height: 4)

                            Rectangle()
                                .fill(Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]))
                                .frame(width: 175, height: 4)
                                .offset(x: self.friendTab ? 0 : 175)
                        }
                    } else {
                        Rectangle()
                            .fill(Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]))
                            .frame(width: 175 * 2, height: 4)
                            .overlay {
                                Text("친구 목록 \(self.userProfileVM.friendCount)")
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundColor(Color(0x1DAFFF))
                                    .offset(y: -24)
                            }
                            .padding(.top, 24)
                    }
                }

                HStack {
                    Image("search")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(0xACACAC))
                    TextField("검색어를 입력하세요", text: self.$searchWord)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0xACACAC))
                }
                .padding(.all, 10)
                .background(Color(0xF1F1F5))
                .cornerRadius(15)
                .padding(.horizontal, 20)

                ScrollView {
                    LazyVStack(spacing: 30) {
                        ForEach(self.friendTab ?
                            self.userProfileVM.friendList : self.userProfileVM.requestFriendList, id: \.id)
                        { user in
                            HStack {
                                NavigationLink {
                                    ProfileView(
                                        postVM: PostViewModel(targetId: user.id, option: .target_feed),
                                        userProfileVM: UserProfileViewModel(userId: user.id)
                                    )
                                } label: {
                                    HStack(spacing: 16) {
                                        switch self.userProfileVM.option {
                                        case .friendList:
                                            if let profileImage = userProfileVM.friProfileImageList[user.id] {
                                                ProfileImgView(profileImage: profileImage)
                                                    .frame(width: 30, height: 30)
                                            } else {
                                                Image("background-main-splash")
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 30, height: 30)
                                            }
                                        case .requestFriendList:
                                            if let profileImage = userProfileVM.reqFriProImageList[user.id] {
                                                ProfileImgView(profileImage: profileImage)
                                                    .frame(width: 30, height: 30)
                                            } else {
                                                Image("background-main-splash")
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 30, height: 30)
                                            }
                                        }

                                        Text(user.name)
                                            .font(.pretendard(size: 16, weight: .bold))
                                    }
                                }
                                .foregroundColor(Color(0x191919))

                                Spacer()

                                if self.userProfileVM.isMe {
                                    self.myFriendView(user: user)
                                } else {
                                    self.otherFriendView(user: user)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        switch self.userProfileVM.option {
                        case .friendList:
                            if !self.userProfileVM.friendList.isEmpty,
                               self.userProfileVM.page <= self.userProfileVM.friendListTotalPage
                            {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .onAppear {
                                            print("더 불러오기")
                                            self.userProfileVM.loadMoreFriendList()
                                        }
                                    Spacer()
                                }
                            }
                        case .requestFriendList:
                            if !self.userProfileVM.requestFriendList.isEmpty,
                               self.userProfileVM.page <= self.userProfileVM.reqFriListTotalPage
                            {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .onAppear {
                                            print("더 불러오기")
                                            self.userProfileVM.loadMoreFriendList()
                                        }
                                    Spacer()
                                }
                            }
                        }
                    }
                } // Scroll
                .onAppear {
                    print("init")
                    self.userProfileVM.initLoad()
                }
            } // VStack
            .padding(.top, 20)
        } // ZStack
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("친구")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }
        }
    }

    @ViewBuilder
    func myFriendView(user: FriendUser) -> some View {
        if self.friendTab {
            HStack(spacing: 10) {
                Button {
                    self.deleteFriend = true
                } label: {
                    Text("삭제")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
                .confirmationDialog(
                    "\(user.name)님을 친구 목록에서 삭제할까요?",
                    isPresented: self.$deleteFriend,
                    titleVisibility: .visible
                ) {
                    Button("삭제하기", role: .destructive) {
                        self.userProfileVM.deleteFriend(friendId: user.id) {
                            self.userProfileVM.refreshFriendList()
                        }
                    }
                }

                Button {} label: {
                    Image("more")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
        } else {
            HStack(spacing: 10) {
                Button {
                    self.userProfileVM.acceptRequestFriend(requesterId: user.id) { result in
                        switch result {
                        case let .success(success):
                            if !success {
                                print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                            }

                            self.userProfileVM.refreshFriendList()

                        case let .failure(failure):
                            print("[Debug] \(failure) \(#file) \(#function)")
                        }
                    }
                } label: {
                    Text("수락")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)])
                        )
                        .cornerRadius(10)
                }

                Button {
                    self.refuseFriend = true
                } label: {
                    Text("거절")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
                .confirmationDialog(
                    "\(user.name)님의 친구 신청을 거절할까요?",
                    isPresented: self.$refuseFriend,
                    titleVisibility: .visible
                ) {
                    Button("거절하기", role: .destructive) {
                        print("거절하기")
                    }
                }
            }
        }
    }

    @ViewBuilder
    func otherFriendView(user: FriendUser) -> some View {
        HStack {
            if user.id == Global.shared.user?.user.id {
                Text("나")
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundColor(Color(0x646464))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(0xF1F1F5))
                    .cornerRadius(10)
            } else if user.friendStatus == 0 {
                Button {
                    self.userProfileVM.requestFriend(acceptorId: user.id) { result in
                        switch result {
                        case let .success(success):
                            if !success {
                                print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                            }

                            self.userProfileVM.refreshFriendList()
                        case let .failure(failure):
                            print("[Debug] \(failure) \(#file) \(#function)")
                        }
                    }
                } label: {
                    Text("친구 신청")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)])
                        )
                        .cornerRadius(10)
                }
            } else if user.friendStatus == 1 {
                Button {
                    self.cancelFriend = true
                } label: {
                    Text("신청 취소")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
                .confirmationDialog(
                    "\(user.name)님께 보낸 친구 신청을 취소할까요?",
                    isPresented: self.$cancelFriend,
                    titleVisibility: .visible
                ) {
                    Button("취소하기", role: .destructive) {
                        self.userProfileVM.cancelRequestFriend(acceptorId: user.id) { result in
                            switch result {
                            case let .success(success):
                                if !success {
                                    print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                                }

                                self.userProfileVM.refreshFriendList()
                            case let .failure(failure):
                                print("[Debug] \(failure) \(#file) \(#function)")
                            }
                        }
                    }
                }

            } else {
                Button {
                    self.deleteFriend = true
                } label: {
                    Text("내 친구")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
                .confirmationDialog(
                    "\(user.name)님을 친구 목록에서 삭제할까요?",
                    isPresented: self.$deleteFriend,
                    titleVisibility: .visible
                ) {
                    Button("삭제하기", role: .destructive) {
                        self.userProfileVM.deleteFriend(friendId: user.id) {
                            self.userProfileVM.refreshFriendList()
                        }
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var deleteFriend: Bool = false
    @State private var refuseFriend: Bool = false
    @State private var cancelFriend: Bool = false
}
