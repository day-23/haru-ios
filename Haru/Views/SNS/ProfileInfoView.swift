//
//  ProfileInfoView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileInfoView: View {
    @StateObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        // ---
        
        HStack(spacing: 20) {
            ProfileImgView(profileImage: userProfileVM.profileImage)
                .frame(width: 62, height: 62)
            
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
    }
}
