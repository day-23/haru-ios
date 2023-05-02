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

    var body: some View {
        VStack(alignment: .leading) {
            // FIXME: 네비게이션바 완성되면 삭제하기
            Group {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("HARU")
                        Image(systemName: isSelecting ? "chevron.down" : "chevron.forward")

                        Spacer()
                        NavigationLink {
                            FallowView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .renderingMode(.template)
                                .foregroundColor(.mainBlack)
                                .fontWeight(.bold)
                        }
                    }
                    Spacer()
                    NavigationLink {
                        Text("둘러보기")
                    } label: {
                        Text("둘러보기")
                    }
                    Spacer()
                    NavigationLink {
                        ProfileInfoView(snsVM: snsVM)
                            .onAppear {
                                snsVM.fetchProfileImg()
                            }
                    } label: {
                        Text("내 기록")
                    }
                    Spacer()
                }

                FeedListView(snsVM: snsVM, feedList: $snsVM.feedList)
            }
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
