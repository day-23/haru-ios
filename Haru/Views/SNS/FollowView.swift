//
//  FallowView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FollowView: View {
    @StateObject var userProfileVM: UserProfileViewModel
    
    @State var isFollowing: Bool
    @State var searchWord: String = ""
    
    @State var cancelFollowingModalVis: Bool = false // 팔로윙을 취소하는 모달창
    @State var addFollowModalVis: Bool = false // 팔로우 신청을 하는 모달창
    
    @State var targetUser: User?
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("팔로윙")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(isFollowing ? .gradientStart1 : .mainBlack)
                            .onTapGesture {
                                withAnimation {
                                    isFollowing = true
                                }
                            }
                        
                        Text("팔로워")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(isFollowing ? .mainBlack : .gradientStart1)
                            .onTapGesture {
                                withAnimation {
                                    isFollowing = false
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
                            .offset(x: isFollowing ? 0 : 175)
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
                        ForEach(isFollowing ? userProfileVM.followingList : userProfileVM.followerList, id: \.self) { user in
                            HStack {
                                NavigationLink {
                                    ProfileInfoView(
                                        postVM: PostViewModel(postOption: PostOption.target_all, targetId: user.id),
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
                                Button {
                                    targetUser = user
                                    if user.isFollowing {
                                        withAnimation {
                                            cancelFollowingModalVis = true
                                        }
                                    } else {
                                        withAnimation {
                                            addFollowModalVis = true
                                        }
                                    }
                                } label: {
                                    Image("ellipsis")
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                } // Scroll
            } // VStack
            
            if cancelFollowingModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            cancelFollowingModalVis = false
                        }
                    }

                Modal(isActive: $cancelFollowingModalVis, ratio: 0.4) {
                    VStack(spacing: 12) {
                        if let user = targetUser {
                            if let profileImage = user.profileImage {
                                ProfileImgView(imageUrl: URL(string: profileImage))
                                    .frame(width: 70, height: 70)
                            } else {
                                Image("default-profile-image")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 70, height: 70)
                            }
                            Text(user.name)
                                .font(.pretendard(size: 20, weight: .bold))
                            Text("팔로우를 취소하시겠습니까?")
                                .font(.pretendard(size: 16, weight: .regular))
                            
                            Spacer()
                                .frame(height: 30)
                            
                            HStack {
                                Button {
                                    cancelFollowingModalVis = false
                                } label: {
                                    Text("취소")
                                        .font(.pretendard(size: 20, weight: .regular))
                                }
                                
                                Spacer()
                                
                                Button {
                                    userProfileVM.cancelFollowing(followingId: user.id) {
                                        userProfileVM.fetchFollowing(currentPage: 1)
                                        userProfileVM.fetchFollower(currentPage: 1)
                                    }
                                    cancelFollowingModalVis = false
                                } label: {
                                    Text("확인")
                                        .font(.pretendard(size: 20, weight: .regular))
                                        .foregroundColor(Color(0xF71E58))
                                }
                            }
                            .padding(.horizontal, 60)
                        }
                    }
                    .padding(.top, 20)
                }
                .transition(.modal)
                .zIndex(2)
            }
            
            if addFollowModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            addFollowModalVis = false
                        }
                    }

                Modal(isActive: $addFollowModalVis, ratio: 0.4) {
                    VStack(spacing: 12) {
                        if let user = targetUser {
                            if let profileImage = user.profileImage {
                                ProfileImgView(imageUrl: URL(string: profileImage))
                                    .frame(width: 70, height: 70)
                            } else {
                                Image("default-profile-image")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 70, height: 70)
                            }
                            Text(user.name)
                                .font(.pretendard(size: 20, weight: .bold))
                            Text("팔로우를 신청하시겠습니까?")
                                .font(.pretendard(size: 16, weight: .regular))
                            
                            Spacer()
                                .frame(height: 30)
                            
                            HStack {
                                Button {
                                    addFollowModalVis = false
                                } label: {
                                    Text("취소")
                                        .font(.pretendard(size: 20, weight: .regular))
                                }
                                
                                Spacer()
                                
                                Button {
                                    userProfileVM.addFollowing(followId: user.id) {
                                        userProfileVM.fetchFollower(currentPage: 1)
                                        userProfileVM.fetchFollowing(currentPage: 1)
                                    }
                                    addFollowModalVis = false
                                } label: {
                                    Text("확인")
                                        .font(.pretendard(size: 20, weight: .regular))
                                        .foregroundColor(Color(0xF71E58))
                                }
                            }
                            .padding(.horizontal, 60)
                        }
                    }
                    .padding(.top, 20)
                }
                .transition(.modal)
                .zIndex(2)
            }
        } // ZStack
    }
}
