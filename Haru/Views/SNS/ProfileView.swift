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
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader(
                    toggleIsClicked: $toggleIsClicked
                ) {
                    // TODO: 검색 뷰 만들어주기
                    Text("검색창")
                }
                .padding(.bottom, 20)
                
                ProfileInfoView(userProfileVM: userProfileVM)
                
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
                    FeedListView(postVM: postVM)
                } else {
                    MediaListView(postVM: postVM)
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
            userProfileVM.fetchUserProfile()
//            userProfileVM.fetchFollower(currentPage: 1)
//            userProfileVM.fetchFollowing(currentPage: 1)
        }
    }
}
