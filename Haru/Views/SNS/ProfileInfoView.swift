//
//  ProfileInfoView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileInfoView: View {
    @Environment(\.dismiss) var dismissAction

    @State var toggleIsClicked: Bool = false
    @State private var isFeedSelected: Bool = true
    var isMine: Bool {
        userProfileVM.user.id == Global.shared.user?.id
    }

    var postVM: PostViewModel
    var userProfileVM: UserProfileViewModel

    init(postVM: PostViewModel, userProfileVM: UserProfileViewModel) {
        self.postVM = postVM
        self.userProfileVM = userProfileVM
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader(
                    toggleIsClicked: $toggleIsClicked,
                    backgroundGradient: Gradient(colors: [.gradientStart2, .gradientEnd2])
                ) {
                    FallowView()
                }
                .padding(.bottom, 10)
                
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
                        if isMine {
                            NavigationLink {
                                // FIXME:
                                ProfileFormView(
                                    userProfileVM: userProfileVM,
                                    name: Global.shared.user?.name ?? "unknown",
                                    introduction: Global.shared.user?.introduction ?? ""
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
                                    print("팔로우 취소")
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
                                    print("팔로우 신청")
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
                    VStack {
                        Text("\(userProfileVM.user.followingCount)")
                            .font(.pretendard(size: 20, weight: .bold))
                        Text("팔로우")
                            .font(.pretendard(size: 14, weight: .regular))
                    }
                    Spacer()
                    VStack {
                        Text("\(userProfileVM.user.followerCount)")
                            .font(.pretendard(size: 20, weight: .bold))
                        Text("팔로워")
                            .font(.pretendard(size: 14, weight: .regular))
                    }
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 20)
                
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
                    isMine ?
                        Text("내 기록")
                        .foregroundColor(Color(0x1DAFFF))
                        :
                        Text("친구 기록")
                        .foregroundColor(Color(0x1DAFFF))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
