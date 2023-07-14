//
//  ProfileInfoView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileInfoView: View {
    @StateObject var userProfileVM: UserProfileViewModel
    
    @State var postOptModalVis: Bool = false
    
    @State var deleteFriend: Bool = false
    @State var cancelFriend: Bool = false
    
    var body: some View {
        VStack(spacing: 26) {
            HStack(alignment: .center, spacing: 20) {
                ProfileImgView(imageUrl: userProfileVM.profileImageURL)
                    .frame(width: 62, height: 62)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(userProfileVM.isPublic ? userProfileVM.user.name : "비공계 계정")
                            .font(.pretendard(size: 20, weight: .bold))
                            .allowsTightening(true)
                            .lineLimit(1)
                        if !userProfileVM.isPublic {
                            Image("setting-privacy-lock")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    if !userProfileVM.user.introduction.isEmpty {
                        Text(userProfileVM.user.introduction)
                            .allowsTightening(true)
                            .lineLimit(1)
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x191919))
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if userProfileVM.isMe {
                        NavigationLink {
                            // FIXME:
                            ProfileFormView(
                                userProfileVM: userProfileVM,
                                name: userProfileVM.user.name,
                                introduction: userProfileVM.user.introduction
                            )
                        } label: {
                            Text("프로필 편집")
                                .foregroundColor(Color(0x646464))
                                .font(.pretendard(size: 16, weight: .regular))
                                .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                .background(Color(0xF1F1F5))
                                .cornerRadius(10)
                        }
                    } else {
                        if userProfileVM.user.friendStatus == 0 {
                            Button {
                                userProfileVM.requestFriend(acceptorId: userProfileVM.user.id) { result in
                                    switch result {
                                    case .success(let success):
                                        if !success {
                                            print("Toast 메시지로 탈퇴한 사용자라고 알려주기")
                                        } else {
                                            userProfileVM.fetchUserProfile()
                                        }
                                    case .failure(let failure):
                                        print("[Debug] \(failure) \(#function) \(#file)")
                                    }
                                }
                            } label: {
                                Text("친구 신청")
                                    .foregroundColor(.white)
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                    .background(
                                        Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)])
                                    )
                                    .cornerRadius(10)
                            }
                        } else if userProfileVM.user.friendStatus == 1 {
                            Button {
                                cancelFriend = true
                            } label: {
                                Text("신청 취소")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(0xF1F1F5))
                                    .cornerRadius(10)
                            }
                            .confirmationDialog(
                                "\(userProfileVM.user.name)님께 보낸 친구 신청을 취소할까요?",
                                isPresented: $cancelFriend,
                                titleVisibility: .visible
                            ) {
                                Button("삭제하기", role: .destructive) {
                                    userProfileVM.deleteFriend(friendId: userProfileVM.user.id) {
                                        userProfileVM.fetchUserProfile()
                                    }
                                }
                            }
                        } else if userProfileVM.user.friendStatus == 3 {
                            // TODO: friendStatus 하나 더 구분해서 수락 기능
                            Button {
                                userProfileVM.acceptRequestFriend(requesterId: userProfileVM.user.id) { result in
                                    switch result {
                                    case .success(let success):
                                        if !success {
                                            print("Toast message로 해당 사용자가 탈퇴했다고 알려주기")
                                        }
                                        
                                        userProfileVM.fetchUserProfile()
                                        
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
                        } else {
                            Button {
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
                            .confirmationDialog(
                                "\(userProfileVM.user.name)님을 친구 목록에서 삭제할까요?",
                                isPresented: $deleteFriend,
                                titleVisibility: .visible
                            ) {
                                Button("삭제하기", role: .destructive) {
                                    userProfileVM.deleteFriend(friendId: userProfileVM.user.id) {
                                        userProfileVM.fetchUserProfile()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 3) {
                    Text("\(userProfileVM.user.postCount)")
                        .font(.pretendard(size: 20, weight: .bold))
                    Text("하루")
                        .font(.pretendard(size: 16, weight: .regular))
                }
                .frame(width: 78)
                .foregroundColor(Color(0x191919))
                
                Spacer(minLength: 96)
                
                NavigationLink {
                    FriendView(userProfileVM: userProfileVM)
                } label: {
                    VStack(spacing: 4) {
                        Text("\(userProfileVM.user.friendCount)")
                            .font(.pretendard(size: 20, weight: .bold))
                        Text("친구")
                            .font(.pretendard(size: 16, weight: .regular))
                    }
                }
                .frame(width: 78)
                .foregroundColor(Color(0x191919))
                
                Spacer()
            }
        }
    }
}
