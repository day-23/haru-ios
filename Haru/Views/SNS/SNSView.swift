//
//  SNSView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct SNSView: View {
    @State var toggleIsClicked: Bool = false

    // For pop up to root
    @State var isActive: Bool = false

    var postVM = PostViewModel()
    var myPostVM = PostViewModel(targetId: Global.shared.user?.id ?? nil)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HaruHeader(
                    toggleIsClicked: $toggleIsClicked,
                    backgroundGradient: Gradient(colors: [.gradientStart2, .gradientEnd2])
                ) {
                    Text("검색창")
                }
                FeedListView(postVM: postVM, comeToRoot: true)
                    .onAppear {
                        postVM.loadMorePosts(option: .main)
                    }
            }

            if toggleIsClicked {
                DropdownMenu {
                    Text("친구피드")
                        .foregroundColor(Color(0x1DAFFF))
                } secondContent: {
                    NavigationLink {
                        LookAroundView()
                    } label: {
                        Text("둘러보기")
                    }
                } thirdContent: {
                    NavigationLink {
                        ProfileInfoView(
                            postVM: myPostVM,
                            userProfileVM: UserProfileViewModel(userId: Global.shared.user?.id ?? "unknown")
                        )
                        .onAppear {
                            myPostVM.loadMorePosts(option: .target_feed)
                        }
                    } label: {
                        Text("내 기록")
                    }
                }
            }

            NavigationLink(
                destination: PostFormView(rootIsActive: $isActive),
                isActive: $isActive
            ) {
                Image("sns-add-button")
                    .shadow(radius: 10, x: 5, y: 0)
            }
            .zIndex(5)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
