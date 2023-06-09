//
//  LookAroundView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct LookAroundView: View {
    @Environment(\.dismiss) var dismissAction

    @State var toggleIsClicked: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
//                self.HaruHeaderView()
                MediaListView(postVM: PostViewModel(option: .media))
            }

            if self.toggleIsClicked {
                DropdownMenu {
                    Button {
//                        toggleIsClicked = false
                        self.dismissAction.callAsFunction()
                    } label: {
                        Text("친구피드")
                            .font(.pretendard(size: 16, weight: .bold))
                    }
                } secondContent: {
                    Text("둘러보기")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x1DAFFF))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

//    @ViewBuilder
//    func HaruHeaderView() -> some View {
//        HaruHeader(toggleIsClicked: self.$toggleIsClicked) {
//            HStack(spacing: 10) {
//                NavigationLink {
//                    ProfileView(
//                        postVM: PostViewModel(targetId: Global.shared.user?.id ?? nil, option: .target_feed),
//                        userProfileVM: UserProfileViewModel(userId: Global.shared.user?.id ?? "unknown"),
//                        myProfile: true
//                    )
//                } label: {
//                    Text("내 기록")
//                        .font(.pretendard(size: 16, weight: .bold))
//                        .foregroundColor(Color(0x191919))
//                        .padding(.vertical, 5)
//                        .padding(.horizontal, 10)
//                        .background(
//                            //                                            ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                            LinearGradient(colors: [Color(0xFDFDFD)], startPoint: .leading, endPoint: .trailing)
//                        )
//                        .cornerRadius(10)
//                        .overlay(content: {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(
//                                    LinearGradient(
//                                        colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ),
//                                    lineWidth: 1
//                                )
//
//                        })
//                        .padding(.vertical, 1)
//                }
//
//                NavigationLink {
//                    // TODO: 검색 뷰 만들어지면 넣어주기
//                    Text("검색")
//                } label: {
//                    Image("search")
//                        .renderingMode(.template)
//                        .resizable()
//                        .foregroundColor(Color(0x191919))
//                        .frame(width: 28, height: 28)
//                }
//            }
//        }
//    }
}

// struct LookAroundView_Previews: PreviewProvider {
//    static var previews: some View {
//        LookAroundView()
//    }
// }
