//
//  FallowView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FriendView: View {
    @Environment(\.dismiss) var dismissAction
    
    @StateObject var userProfileVM: UserProfileViewModel
    
    @State var friendTab: Bool = true
    @State var searchWord: String = ""
    
    @State var deleteFriendModalVis: Bool = false
    
    @State var cancelFollowingModalVis: Bool = false // 팔로윙을 취소하는 모달창
    @State var addFollowModalVis: Bool = false // 팔로우 신청을 하는 모달창
    
    @State var targetUser: User?
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("친구 목록")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(friendTab ? .gradientStart1 : .mainBlack)
                            .onTapGesture {
                                withAnimation {
                                    friendTab = true
                                }
                            }
                        
                        Text("친구 신청")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(friendTab ? .mainBlack : .gradientStart1)
                            .onTapGesture {
                                withAnimation {
                                    friendTab = false
                                }
                            }
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.gray4)
                            .frame(width: 175 * 2, height: 4)
                        
                        Rectangle()
                            .fill(.gradation2)
                            .frame(width: 175, height: 4)
                            .offset(x: friendTab ? 0 : 175)
                    }
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.template)
                        .foregroundColor(.gray2)
                        .fontWeight(.bold)
                    TextField("검색어를 입력하세요", text: $searchWord)
                        .foregroundColor(.gray2)
                }
                .padding(.all, 10)
                .background(Color(0xF1F1F5))
                .cornerRadius(15)
                .padding(.horizontal, 20)
                
                ScrollView {
                    LazyVStack(spacing: 30) {
                        ForEach(friendTab ? userProfileVM.friendList : userProfileVM.requestFriendList, id: \.self) { user in
                            HStack {
                                NavigationLink {
                                    ProfileView(
                                        postVM: PostViewModel(targetId: user.id, option: .target_feed),
                                        userProfileVM: UserProfileViewModel(userId: user.id)
                                    )
                                } label: {
                                    HStack(spacing: 16) {
                                        if let profileImage = user.profileImage {
                                            ProfileImgView(imageUrl: URL(string: profileImage))
                                                .frame(width: 30, height: 30)
                                        } else {
                                            Image("default-profile-image")
                                                .resizable()
                                                .clipShape(Circle())
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        Text(user.name)
                                            .font(.pretendard(size: 16, weight: .bold))
                                    }
                                }
                                .foregroundColor(Color(0x191919))
                                
                                Spacer()
                                
                                if friendTab {
                                    HStack(spacing: 10) {
                                        Button {
                                            targetUser = user
                                            // TODO: 삭제 버튼 눌렀을 때 actionSheet 나오게하기
                                            print("삭제")
                                        } label: {
                                            Text("삭제")
                                                .font(.pretendard(size: 16, weight: .regular))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(0xF1F1F5))
                                                .cornerRadius(10)
                                        }
                                        
                                        Button {
                                            targetUser = user
                                            print("뭐가 나와야하는거지")
                                        } label: {
                                            Image("ellipsis")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                        }
                                    }
                                } else {
                                    HStack(spacing: 10) {
                                        Button {
                                            targetUser = user
                                            // TODO: 수락 버튼 눌렀을 때 actionSheet 나오게하기
                                            print("수락")
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
                                            // TODO: 거절 버튼 눌렀을 때 actionSheet 나오게하기
                                            print("거절")
                                        } label: {
                                            Text("거절")
                                                .font(.pretendard(size: 16, weight: .regular))
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
                } // Scroll
            } // VStack
        } // ZStack
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    Text("검색창")
                } label: {
                    Image("magnifyingglass")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(0x191919))
                }
            }
        }

//            if deleteFriendModalVis {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all)
//                    .zIndex(1)
//                    .onTapGesture {
//                        withAnimation {
//                            deleteFriendModalVis = false
//                        }
//                    }
//
//                Modal(isActive: $deleteFriendModalVis, ratio: 0.4) {
//                    VStack(spacing: 12) {
//                        if let user = targetUser {
//                            if let profileImage = user.profileImage {
//                                ProfileImgView(imageUrl: URL(string: profileImage))
//                                    .frame(width: 70, height: 70)
//                            } else {
//                                Image("default-profile-image")
//                                    .resizable()
//                                    .clipShape(Circle())
//                                    .frame(width: 70, height: 70)
//                            }
//                            Text(user.name)
//                                .font(.pretendard(size: 20, weight: .bold))
//                            Text("친구를 목록에서 삭제할까요?")
//                                .font(.pretendard(size: 14, weight: .regular))
//
//                            Divider()
//
//
//
//                            HStack {
//                                Button {
//                                    cancelFollowingModalVis = false
//                                } label: {
//                                    Text("취소")
//                                        .font(.pretendard(size: 20, weight: .regular))
//                                }
//
//                                Spacer()
//
//                                Button {
        ////                                    userProfileVM.cancelFollowing(followingId: user.id) {
        ////                                        userProfileVM.fetchFollowing(currentPage: 1)
        ////                                        userProfileVM.fetchFollower(currentPage: 1)
        ////                                    }
        ////                                    cancelFollowingModalVis = false
//                                } label: {
//                                    Text("확인")
//                                        .font(.pretendard(size: 20, weight: .regular))
//                                        .foregroundColor(Color(0xF71E58))
//                                }
//                            }
//                            .padding(.horizontal, 60)
//                        }
//                    }
//                    .padding(.top, 20)
//                }
//                .transition(.modal)
//                .zIndex(2)
//            }
//
//            if addFollowModalVis {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all)
//                    .zIndex(1)
//                    .onTapGesture {
//                        withAnimation {
//                            addFollowModalVis = false
//                        }
//                    }
//
//                Modal(isActive: $addFollowModalVis, ratio: 0.4) {
//                    VStack(spacing: 12) {
//                        if let user = targetUser {
//                            if let profileImage = user.profileImage {
//                                ProfileImgView(imageUrl: URL(string: profileImage))
//                                    .frame(width: 70, height: 70)
//                            } else {
//                                Image("default-profile-image")
//                                    .resizable()
//                                    .clipShape(Circle())
//                                    .frame(width: 70, height: 70)
//                            }
//                            Text(user.name)
//                                .font(.pretendard(size: 20, weight: .bold))
//                            Text("팔로우를 신청하시겠습니까?")
//                                .font(.pretendard(size: 16, weight: .regular))
//
//                            Spacer()
//                                .frame(height: 30)
//
//                            HStack {
//                                Button {
//                                    addFollowModalVis = false
//                                } label: {
//                                    Text("취소")
//                                        .font(.pretendard(size: 20, weight: .regular))
//                                }
//
//                                Spacer()
//
//                                Button {
        ////                                    userProfileVM.addFollowing(followId: user.id) {
        ////                                        userProfileVM.fetchFollower(currentPage: 1)
        ////                                        userProfileVM.fetchFollowing(currentPage: 1)
        ////                                    }
        ////                                    addFollowModalVis = false
//                                } label: {
//                                    Text("확인")
//                                        .font(.pretendard(size: 20, weight: .regular))
//                                        .foregroundColor(Color(0xF71E58))
//                                }
//                            }
//                            .padding(.horizontal, 60)
//                        }
//                    }
//                    .padding(.top, 20)
//                }
//                .transition(.modal)
//                .zIndex(2)
//            }
    }
}
