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

    @State var isSelecting: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 8) {
                HStack {
                    Text("HARU")
                    Image(systemName: isSelecting ? "chevron.down" : "chevron.forward")
                }
                .onTapGesture {
                    isSelecting.toggle()
                }

                if isSelecting {
                    NavigationLink {
                        // go some View
                        Text("친구 피드")
                    } label: {
                        Text("친구 피드")
                    }
                    NavigationLink {
                        // go some View
                        LookAroundView()
                    } label: {
                        Text("둘러보기")
                    }
                    NavigationLink {
                        ProfileInfoView(snsVM: snsVM)
                            .onAppear {
                                snsVM.fetchProfileImg()
                            }
                    } label: {
                        Text("내 기록")
                    }
                }
            }
            .padding(.leading, 20)

            FeedListView(snsVM: snsVM, feedList: $snsVM.feedList)
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
