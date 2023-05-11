//
//  ProfileInfoView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismissAction

    @State var toggleIsClicked: Bool = false
    @State private var isFeedSelected: Bool = true

    var postVM: PostViewModel
    @StateObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader(
                    toggleIsClicked: $toggleIsClicked,
                    backgroundGradient: Gradient(colors: [.gradientStart2, .gradientEnd2])
                ) {
                    // TODO: 검색 뷰 만들어주기
                    Text("검색창")
                }
                .padding(.bottom, 20)
                
                // ---
                
                HStack(spacing: 20) {
                    if let profileImage = userProfileVM.user.profileImage {
                        ProfileImgView(imageUrl: URL(string: profileImage))
                            .frame(width: 62, height: 62)
                    } else {
                        Image("default-profile-image")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 62, height: 62)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userProfileVM.user.name)
                            .font(.pretendard(size: 20, weight: .bold))
                        Text(userProfileVM.user.introduction)
                            .font(.pretendard(size: 14, weight: .regular))
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
                                    .foregroundColor(.mainBlack)
                                    .font(.pretendard(size: 14, weight: .bold))
                                    .frame(width: 64, height: 16)
                                    .padding(EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 9)
                                            .stroke(.gradation2, lineWidth: 1)
                                    )
                            }
                            Text("프로필 공유")
                                .font(.pretendard(size: 14, weight: .bold))
                                .frame(width: 64, height: 16)
                                .padding(EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(.gradation2, lineWidth: 1)
                                )
                        } else {
                            if userProfileVM.user.isFollowing {
                                Button {
                                    userProfileVM.cancelFollowing(followingId: userProfileVM.user.id) {}
                                } label: {
                                    Text("팔로우 취소")
                                        .foregroundColor(.mainBlack)
                                        .font(.pretendard(size: 14, weight: .bold))
                                        .frame(width: 64, height: 16)
                                        .padding(EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 9)
                                                .stroke(.gradation2, lineWidth: 1)
                                        )
                                }
                            } else {
                                Button {
                                    userProfileVM.addFollowing(followId: userProfileVM.user.id) {}
                                } label: {
                                    Text("팔로우 신청")
                                        .foregroundColor(.mainBlack)
                                        .font(.pretendard(size: 14, weight: .bold))
                                        .frame(width: 64, height: 16)
                                        .padding(EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11))
                                        .background(Color(0xEDEDED))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    Spacer()
                    VStack {
                        Text("\(userProfileVM.user.postCount)")
                            .font(.pretendard(size: 20, weight: .bold))
                        Text("하루")
                            .font(.pretendard(size: 14, weight: .regular))
                    }
                    Spacer()
                    
                    NavigationLink {
                        FollowView(userProfileVM: userProfileVM, isFollowing: true)
                    } label: {
                        VStack {
                            Text("\(userProfileVM.user.followingCount)")
                                .font(.pretendard(size: 20, weight: .bold))
                            Text("팔로윙")
                                .font(.pretendard(size: 14, weight: .regular))
                        }
                    }
                    .foregroundColor(Color(0x191919))
                    
                    Spacer()
                    
                    NavigationLink {
                        FollowView(userProfileVM: userProfileVM, isFollowing: false)
                    } label: {
                        VStack {
                            Text("\(userProfileVM.user.followerCount)")
                                .font(.pretendard(size: 20, weight: .bold))
                            Text("팔로워")
                                .font(.pretendard(size: 14, weight: .regular))
                        }
                    }
                    .foregroundColor(Color(0x191919))
                    
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 38)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("내 피드")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(isFeedSelected ? .gradientStart1 : .mainBlack)
                            .onTapGesture {
                                withAnimation {
                                    isFeedSelected = true
                                }
                            }
                        
                        Text("미디어")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(isFeedSelected ? .mainBlack : .gradientStart1)
                            .onTapGesture {
                                withAnimation {
                                    isFeedSelected = false
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
                            .offset(x: isFeedSelected ? 0 : 175)
                    }
                }
                
                if isFeedSelected {
                    Spacer()
                        .frame(height: 20)
                    FeedListView(postVM: postVM)
                } else {
                    MediaView()
                }
            }
            
            if toggleIsClicked {
                DropdownMenu {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Text("친구피드")
                    }
                } secondContent: {
                    NavigationLink {
                        LookAroundView()
                    } label: {
                        Text("둘러보기")
                    }
                } thirdContent: {
                    userProfileVM.isMe ?
                        Text("내 기록")
                        .foregroundColor(Color(0x1DAFFF))
                        :
                        Text("친구 기록")
                        .foregroundColor(Color(0x1DAFFF))
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
//            postVM.loadMorePosts()
            userProfileVM.fetchFollower(currentPage: 1)
            userProfileVM.fetchFollowing(currentPage: 1)
        }
    }
}
