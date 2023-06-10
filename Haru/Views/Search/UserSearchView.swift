//
//  UserSearchView.swift
//  Haru
//
//  Created by 이준호 on 2023/06/10.
//

import SwiftUI

struct UserSearchView: View {
    @Environment(\.dismiss) var dismissAction
    
    @State var searchUserHaruId: String = ""
    @FocusState var focus: Bool
    @State var waitingResponse: Bool = false
    
    @State var targetUser: User?
    
    @State private var deleteFriend: Bool = false
    @State private var refuseFriend: Bool = false
    @State private var cancelFriend: Bool = false
    
    @StateObject var searchVM: SearchViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let user = searchVM.searchUser {
                    searchUserView(user: user)
                } else {
                    Text("그런 사용자는 없습니다.")
                }
            }
        }
        .padding(.top, 25)
        .navigationBarBackButtonHidden()
        .customNavigationBar(leftView: {
            Button {
                dismissAction.callAsFunction()
            } label: {
                Image("back-button")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
        }, rightView: {
            HStack(spacing: 8) {
                Image("magnifyingglass")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color(0xACACAC))
                TextField("검색어를 입력하세요", text: $searchUserHaruId)
                    .disableAutocorrection(true)
                    .font(.pretendard(size: 16, weight: .regular))
                    .focused($focus)
                    .onSubmit {
                        if searchUserHaruId != "" {
                            waitingResponse = true
                            searchVM.searchUserWithHaruId(haruId: searchUserHaruId) {
                                waitingResponse = false
                            }
                        }
                    }
                    .disabled(waitingResponse)
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(0xF1F1F5))
            .cornerRadius(10)
        })
        .confirmationDialog(
            "\(targetUser?.name ?? "")님께 보낸 친구 신청을 취소할까요?",
            isPresented: $cancelFriend,
            titleVisibility: .visible
        ) {
            Button("취소하기", role: .destructive) {
                guard let user = targetUser else {
                    return
                }
                searchVM.cancelRequestFriend(acceptorId: user.id) { result in
                    switch result {
                    case .success(let success):
                        if !success {
                            print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                        }
                        
                        searchVM.refreshFriendList()
                    case .failure(let failure):
                        print("[Debug] \(failure) \(#file) \(#function)")
                    }
                }
            }
        }
        .confirmationDialog(
            "\(targetUser?.name ?? "")님을 친구 목록에서 삭제할까요?",
            isPresented: $deleteFriend,
            titleVisibility: .visible
        ) {
            Button("삭제하기", role: .destructive) {
                guard let user = targetUser else {
                    return
                }
                searchVM.deleteFriend(friendId: user.id) {
                    searchVM.refreshFriendList()
                }
            }
        }
        .confirmationDialog(
            "\(targetUser?.name ?? "")님의 친구 신청을 거절할까요?",
            isPresented: $refuseFriend,
            titleVisibility: .visible
        ) {
            Button("거절하기", role: .destructive) {
                guard let user = targetUser else {
                    return
                }
                searchVM.cancelRequestFriend(acceptorId: user.id) { result in
                    switch result {
                    case .success(let success):
                        if !success {
                            print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                        }
                        
                        searchVM.refreshFriendList()
                    case .failure(let failure):
                        print("[Debug] \(failure) \(#file) \(#function)")
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    @ViewBuilder
    func searchUserView(user: User) -> some View {
        HStack(spacing: 0) {
            NavigationLink {
                ProfileView(
                    postVM: PostViewModel(targetId: user.id, option: .target_feed),
                    userProfileVM: UserProfileViewModel(userId: user.id)
                )
            } label: {
                HStack(spacing: 14) {
                    if let imageUrl = user.profileImage {
                        ProfileImgView(imageUrl: URL(string: imageUrl))
                            .frame(width: 40, height: 40)
                    } else {
                        Image("default-profile-image")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                    }
                    
                    Text(user.name)
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))
                }
            }
            
            Spacer()
            
            if user.friendStatus == 0 {
                if user.id != Global.shared.user?.id {
                    Button {
                        searchVM.requestFriend(acceptorId: user.id) { result in
                            switch result {
                            case .success(let success):
                                if !success {
                                    print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                                }
                                
                                searchVM.refreshFriendList()
                            case .failure(let failure):
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
                } else {
                    Text("나")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
            } else if user.friendStatus == 1 {
                Button {
                    targetUser = user
                    cancelFriend = true
                } label: {
                    Text("신청 취소")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
            } else if user.friendStatus == 2 {
                Button {
                    targetUser = user
                    deleteFriend = true
                } label: {
                    Text("내 친구")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(10)
                }
            } else {
                HStack(spacing: 10) {
                    Button {
                        searchVM.acceptRequestFriend(requesterId: user.id) { result in
                            switch result {
                            case .success(let success):
                                if !success {
                                    print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                                }
                                
                                searchVM.refreshFriendList()
                                
                            case .failure(let failure):
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
                        targetUser = user
                        refuseFriend = true
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
        .padding(.horizontal, 20)
    }
}
