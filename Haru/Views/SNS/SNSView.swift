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
        ZStack {
            VStack(alignment: .leading, spacing: 14) {
                // FIXME: 네비게이션바 완성되면 삭제하기
                HaruHeader(toggleIsClicked: $toggleIsClicked, backgroundGradient: Gradient(colors: [.gradientStart2, .gradientEnd2])) {
                    FallowView()
                }

                FeedListView(snsVM: snsVM, feedList: $snsVM.feedList)
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
                            // go some View
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
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
