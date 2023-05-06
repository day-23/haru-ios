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

    @StateObject var snsVM: SNSViewModel = .init()

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

                FeedListView(snsVM: snsVM, postList: snsVM.mainPostList)
            }

            if toggleIsClicked {
                VStack {
                    Group {
                        NavigationLink {
                            ProfileInfoView(isMine: false, snsVM: snsVM)
                        } label: {
                            Text("친구 피드")
                        }
                        Divider()
                        NavigationLink {
                            LookAroundView()
                        } label: {
                            Text("둘러보기")
                        }
                        Divider()
                        NavigationLink {
                            ProfileInfoView(isMine: true, snsVM: snsVM)
                                .onAppear {
                                    snsVM.fetchProfileImg()
                                }
                        } label: {
                            Text("내 기록")
                        }
                    }
                    .foregroundColor(Color(0x191919))
                }
                .frame(width: 94, height: 96)
                .padding(8)
                .background(.white)
                .cornerRadius(10)
                .position(x: 60, y: 90)
                .transition(.opacity.animation(.easeIn))
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
            snsVM.fetchAllPosts(currentPage: 1)
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
