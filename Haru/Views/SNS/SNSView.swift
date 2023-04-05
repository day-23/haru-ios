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
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink {
                        Text("친구피드")
                    } label: {
                        Text("친구피드")
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
