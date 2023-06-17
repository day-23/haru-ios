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
    
    @State private var searchSuccess: Bool?
    
    @StateObject var searchVM: SearchViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let user = searchVM.searchUser {
                    searchUserView(user: user)
                } else {
                    if let searchSuccess, !searchSuccess {
                        VStack(spacing: 0) {
                            Image("sns-wrong-search")
                                .resizable()
                                .frame(width: 125, height: 205)
                                
                            Text("하루 아이디를 가지는")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0x646464))
                                .padding(.top, 37)
                                
                            Text("친구를 찾을 수 없어요.")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0x646464))
                                .padding(.top, 10)
                        }
                        .padding(.top, 100)
                    } else {
                        VStack(spacing: 0) {
                            Image("sns-empty-search")
                                .resizable()
                                .frame(width: 165, height: 145)
                                
                            Text("하루 아이디 검색을 통해")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0x646464))
                                .padding(.top, 50)
                                
                            Text("친구를 찾을 수 있어요.")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0x646464))
                                .padding(.top, 10)
                        }
                        .padding(.top, 150)
                    }
                }
            }
        }
        .padding(.top, 20)
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
                Image("search")
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
                            searchVM.searchUserWithHaruId(haruId: searchUserHaruId) { success in
                                searchSuccess = success
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
                waitingResponse = true
                searchVM.cancelRequestFriend(acceptorId: user.id) { result in
                    switch result {
                    case .success(let success):
                        if !success {
                            print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                        }
                        
                        searchVM.searchUserWithHaruId(haruId: searchUserHaruId) { success in
                            searchSuccess = success
                            waitingResponse = false
                        }
                    case .failure(let failure):
                        print("[Debug] \(failure) \(#file) \(#function)")
                        waitingResponse = false
                    }
                }
            }
            .disabled(waitingResponse)
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
                waitingResponse = true
                searchVM.deleteFriend(friendId: user.id) {
                    searchVM.searchUserWithHaruId(haruId: searchUserHaruId) { success in
                        searchSuccess = success
                        waitingResponse = false
                    }
                }
            }
            .disabled(waitingResponse)
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
                waitingResponse = true
                searchVM.cancelRequestFriend(acceptorId: user.id) { result in
                    switch result {
                    case .success(let success):
                        if !success {
                            print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                        }
                        
                        searchVM.searchUserWithHaruId(haruId: searchUserHaruId) { success in
                            searchSuccess = success
                            waitingResponse = false
                        }
                    case .failure(let failure):
                        print("[Debug] \(failure) \(#file) \(#function)")
                        waitingResponse = false
                    }
                }
            }
            .disabled(waitingResponse)
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
                        Image("sns-default-profile-image-circle")
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
                        waitingResponse = true
                        searchVM.requestFriend(acceptorId: user.id) { result in
                            switch result {
                            case .success(let success):
                                if !success {
                                    print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                                }
                                searchVM.searchUserWithHaruId(haruId: searchUserHaruId) { success in
                                    searchSuccess = success
                                    waitingResponse = false
                                }
                            case .failure(let failure):
                                print("[Debug] \(failure) \(#file) \(#function)")
                                waitingResponse = false
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
                    .disabled(waitingResponse)
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
                        waitingResponse = true
                        searchVM.acceptRequestFriend(requesterId: user.id) { result in
                            switch result {
                            case .success(let success):
                                if !success {
                                    print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                                }
                                
                                searchVM.searchUserWithHaruId(haruId: searchUserHaruId) { success in
                                    searchSuccess = success
                                    waitingResponse = false
                                }
                                
                            case .failure(let failure):
                                print("[Debug] \(failure) \(#file) \(#function)")
                                waitingResponse = false
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
                    .disabled(waitingResponse)
                    
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
