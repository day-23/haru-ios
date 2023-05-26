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
                    if userProfileVM.user.friendStatus == 0 {
                        Button {
                            // TODO: 친구 신청
                            print("친구 신청")
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
                            // TODO: 신청 취소
                            print("신청 취소")
                        } label: {
                            Text("신청 취소")
                                .font(.pretendard(size: 16, weight: .regular))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(0xF1F1F5))
                                .cornerRadius(10)
                        }
                    } else {
                        Button {
                            // TODO: 친구 삭제
                            print("친구 삭제")
                        } label: {
                            Text("내 친구")
                                .font(.pretendard(size: 16, weight: .regular))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(0xF1F1F5))
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
                FriendView(userProfileVM: userProfileVM)
            } label: {
                VStack {
                    Text("\(userProfileVM.user.friendCount)")
                        .font(.pretendard(size: 20, weight: .bold))
                    Text("친구")
                        .font(.pretendard(size: 14, weight: .regular))
                }
            }
            .foregroundColor(.mainBlack)
            Spacer()
        }
    }
}
