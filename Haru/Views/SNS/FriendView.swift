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

    @State private var deleteFriend: Bool = false
    @State private var refuseFriend: Bool = false
    @State private var cancelFriend: Bool = false

    @FocusState var focus: Bool

    @State var waitingResponse: Bool = false

    @State private var targetUser: FriendUser?
    
    @State var blockModalVis: Bool = false
    @State var blockFriend: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
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
                                .offset(x: self.friendTab ? 0 : 175)
                        }
                    } else {
                        Rectangle()
                            .fill(RadialGradient(
                                colors: [
                                    Color(0xAAD7FF),
                                    Color(0xD2D7FF)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 180
                            ))
                            .frame(width: 175 * 2, height: 4)
                            .overlay {
                                Text("친구 목록 \(self.userProfileVM.friendCount)")
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundColor(Color(0x1DAFFF))
                                    .offset(y: -24)
                            }
                            .padding(.top, 44)
                            .padding(.bottom, -10)
                    }
                }
                
                if self.userProfileVM.isMe {
                    HStack {
                        Image("search")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(0xACACAC))
                        TextField("검색어를 입력하세요", text: self.$searchWord)
                            .font(.pretendard(size: 14, weight: .regular))
                            .focused(self.$focus)
                            .onSubmit {
                                if self.searchWord != "" {
                                    self.waitingResponse = true
                                    self.userProfileVM.searchFriend(name: self.searchWord) {
                                        self.waitingResponse = false
                                    }
                                }
                            }
                            .disabled(self.waitingResponse)
                        
                        Spacer()
                        
                        if self.searchWord != "" {
                            ZStack {
                                Circle()
                                    .fill(Color(0x191919))
                                    .frame(width: 20, height: 20)
                                    .zIndex(1)
                                
                                Image("cancel")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 18, height: 18)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(0xFDFDFD))
                                    .zIndex(2)
                            }
                            .onTapGesture {
                                self.searchWord = ""
                                self.userProfileVM.refreshFriendList()
                            }
                        }
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .background(Color(0xF1F1F5))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                ScrollView {
                    if !self.userProfileVM.isMe {
                        Spacer(minLength: 10)
                    }
                    
                    LazyVStack(spacing: 20) {
                        ForEach(self.friendTab ?
                            self.userProfileVM.friendList.indices : self.userProfileVM.requestFriendList.indices, id: \.self)
                        { idx in
                            let user = self.friendTab ? self.userProfileVM.friendList[idx] : self.userProfileVM.requestFriendList[idx]
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
                                                    .frame(width: 40, height: 40)
                                            } else {
                                                Image("sns-default-profile-image-rectangle")
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 40, height: 40)
                                            }
                                        case .requestFriendList:
                                            if let profileImage = userProfileVM.reqFriProImageList[user.id] {
                                                ProfileImgView(profileImage: profileImage)
                                                    .frame(width: 40, height: 40)
                                            } else {
                                                Image("sns-default-profile-image-rectangle")
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 40, height: 40)
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
                                            self.userProfileVM.loadMoreFriendList()
                                        }
                                    Spacer()
                                }
                            }
                        }
                    }
                } // Scroll
                .refreshable {
                    self.userProfileVM.refreshFriendList()
                }
                .animation(nil, value: UUID())
                .onAppear {
                    print("init")
                    self.userProfileVM.initLoad()
                }
            } // VStack
            .padding(.top, 20)
            .confirmationDialog(
                "\(self.targetUser?.name ?? "")님께 보낸 친구 신청을 취소할까요?",
                isPresented: self.$cancelFriend,
                titleVisibility: .visible
            ) {
                Button("취소하기", role: .destructive) {
                    guard let user = targetUser else {
                        return
                    }
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
            .confirmationDialog(
                "\(self.targetUser?.name ?? "")님을 친구 목록에서 삭제할까요?",
                isPresented: self.$deleteFriend,
                titleVisibility: .visible
            ) {
                Button("삭제하기", role: .destructive) {
                    guard let user = targetUser else {
                        return
                    }
                    self.userProfileVM.deleteFriend(friendId: user.id) {
                        self.userProfileVM.refreshFriendList()
                    }
                }
            }
            .confirmationDialog(
                "\(self.targetUser?.name ?? "")님의 친구 신청을 거절할까요?",
                isPresented: self.$refuseFriend,
                titleVisibility: .visible
            ) {
                Button("거절하기", role: .destructive) {
                    guard let user = targetUser else {
                        return
                    }
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
            
            if self.blockModalVis {
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
                        ProfileImgView(imageUrl: URL(string: self.targetUser?.profileImageUrl ?? ""))
                            .frame(width: 70, height: 70)
                            .padding(.bottom, 12)
                        
                        Text("\(self.targetUser?.name ?? "unknown")")
                            .font(.pretendard(size: 20, weight: .bold))
                            .foregroundColor(Color(0x191919))
                        
                        Divider()
                            .padding(.top, 34)
                            .padding(.bottom, 20)
                        
                        Button {
                            withAnimation {
                                self.blockFriend = true
                            }
                        } label: {
                            Text("이 이용자 차단하기")
                                .font(.pretendard(size: 20, weight: .regular))
                                .foregroundColor(Color(0xF71E58))
                        }.confirmationDialog(
                            "\(self.targetUser?.name ?? "unknown")님을 차단할까요? 차단된 이용자는 내 피드를 볼 수 없으며 나에게 친구 신청을 보낼 수 없습니다. 차단된 이용자에게는 내 계정이 검색되지 않습니다.",
                            isPresented: self.$blockFriend,
                            titleVisibility: .visible
                        ) {
                            Button("차단하기", role: .destructive) {
                                self.userProfileVM.blockedFriend(
                                    blockUserId: self.targetUser?.id ?? "unknown"
                                ) { result in
                                    switch result {
                                    case let .success(success):
                                        if !success {
                                            print("Toast Message로 알려주기")
                                        }
                                        self.userProfileVM.refreshFriendList()
                                        self.blockModalVis = false
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
        } // ZStack
        .onTapGesture {
            hideKeyboard()
        }
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
        .onChange(of: self.blockFriend) { _ in
            if self.blockFriend == false {
                self.blockModalVis = false
            }
        }
    }

    @ViewBuilder
    func myFriendView(user: FriendUser) -> some View {
        if self.friendTab {
            HStack(spacing: 10) {
                Button {
                    self.targetUser = user
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

                Button {
                    // TODO: 친구 차단하기 및 숨기기 기능
                    self.targetUser = user
                    withAnimation {
                        self.blockModalVis = true
                    }
                } label: {
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
                    self.targetUser = user
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
                    self.targetUser = user
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
            } else if user.friendStatus == 3 {
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
                        self.targetUser = user
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
                }
            } else {
                Button {
                    self.targetUser = user
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
            }
        }
    }
}
