//
//  ProfileView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismissAction

    @State var toggleIsClicked: Bool = false
    @State private var isFeedSelected: Bool = true

    @StateObject var postVM: PostViewModel
    @StateObject var userProfileVM: UserProfileViewModel
    
    @State var postOptModalVis: (Bool, Post?) = (false, nil)
    
    var myProfile: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if myProfile {
                    HaruHeaderView()
                }
                
                Spacer()
                    .frame(height: 30)
                
                ProfileInfoView(userProfileVM: userProfileVM)
                
                Spacer()
                    .frame(height: 28)
                
                if userProfileVM.isPublic {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text(userProfileVM.isMe ? "내 피드" : "피드")
                                .frame(width: 175)
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(isFeedSelected ? Color(0x1DAFFF) : Color(0xACACAC))
                                .onTapGesture {
                                    withAnimation {
                                        isFeedSelected = true
                                    }
                                }
                            
                            Text("미디어")
                                .frame(width: 175)
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(isFeedSelected ? Color(0xACACAC) : Color(0x1DAFFF))
                                .onTapGesture {
                                    withAnimation {
                                        isFeedSelected = false
                                    }
                                }
                        }
                        .padding(.bottom, 10)
                        
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
                        FeedListView(postVM: postVM, postOptModalVis: $postOptModalVis)
                    } else {
                        MediaListView(postVM: postVM)
                    }
                } else {
                    VStack(spacing: 0) {
                        Image("bg-picture-1")
                            .resizable()
                            .frame(width: 160, height: 190)
                            .padding(.top, 68)
                            .padding(.bottom, 55)
                        Text("비공개 계정입니다.")
                            .padding(.bottom, 5)
                        Text("수락된 친구만 게시글을 볼 수 있어요.")
                        Spacer()
                    }
                }
            }
            
            if postOptModalVis.0 {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            postOptModalVis.0 = false
                        }
                    }

                Modal(isActive: $postOptModalVis.0, ratio: 0.1) {
                    VStack(spacing: 20) {
                        if postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {} label: {
                                Text("이 게시글 수정하기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        } else {
                            Button {} label: {
                                Text("이 게시글 숨기기")
                                    .foregroundColor(Color(0x646464))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        }
                        Divider()
                        if postOptModalVis.1?.user.id == Global.shared.user?.id {
                            Button {} label: {
                                HStack {
                                    Text("게시글 삭제하기")
                                        .foregroundColor(Color(0xF71E58))
                                        .font(.pretendard(size: 20, weight: .regular))
                                    
                                    Image("trash")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color(0xF71E58))
                                        .frame(width: 28, height: 28)
                                }
                            }
                        } else {
                            Button {} label: {
                                Text("이 게시글 신고하기")
                                    .foregroundColor(Color(0xF71E58))
                                    .font(.pretendard(size: 20, weight: .regular))
                            }
                        }
                    }
                    .padding(.top, 40)
                }
                .transition(.modal)
                .zIndex(2)
            }
            
            if toggleIsClicked {
                DropdownMenu {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Text("친구피드")
                            .font(.pretendard(size: 16, weight: .bold))
                    }
                } secondContent: {
                    NavigationLink {
                        LookAroundView()
                    } label: {
                        Text("둘러보기")
                            .font(.pretendard(size: 16, weight: .bold))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if !myProfile {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Image("back-button")
                            .frame(width: 28, height: 28)
                    }
                }
                
                if !userProfileVM.isMe {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("친구 차단")
                        } label: {
                            Image("ellipsis")
                        }
                    }
                }
            }
        }
        .onAppear {
            userProfileVM.fetchUserProfile()
//            userProfileVM.fetchFollower(currentPage: 1)
//            userProfileVM.fetchFollowing(currentPage: 1)
        }
    }
    
    @ViewBuilder
    func HaruHeaderView() -> some View {
        HaruHeader(
            toggleIsClicked: $toggleIsClicked
        ) {
            HStack(spacing: 10) {
                Text("내 기록")
                    .font(.pretendard(size: 16, weight: .bold))
                    .foregroundColor(Color(0xFDFDFD))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(
                        LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(10)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            
                    })
                    .padding(.vertical, 1)
                
                NavigationLink {
                    Text("검색")
                } label: {
                    Image("magnifyingglass")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(Color(0x191919))
                        .frame(width: 28, height: 28)
                }
            }
        }
    }
}
