//
//  SNSView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct Sns: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let imageURL: URL
    let isLike: Bool
}

struct SNSView: View {
    @State private var maxNumber: Int = 4

    @StateObject var postVM: PostViewModel = .init()

    @State var toggleIsClicked: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 14) {
                HaruHeader(
                    toggleIsClicked: $toggleIsClicked,
                    backgroundGradient: Gradient(colors: [.gradientStart2, .gradientEnd2])
                ) {
                    FallowView()
                }
                FeedListView(postVM: postVM)
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
                            postVM: postVM,
                            userProfileVM: UserProfileViewModel(userId: Global.shared.user?.id ?? "unknown")
                        )
                    } label: {
                        Text("내 기록")
                    }
                }
            }

            NavigationLink {
                PostFormView()
            } label: {
                Image("sns-add-button")
                    .shadow(radius: 10, x: 5, y: 0)
            }
            .zIndex(5)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .onAppear {
            postVM.fetchAllPosts(currentPage: 1)
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
