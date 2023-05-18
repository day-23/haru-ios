//
//  LookAroundView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct LookAroundView: View {
    @Environment(\.dismiss) var dismissAction

    @State var text: String = ""

    var body: some View {
        MediaListView(postVM: PostViewModel(option: .media))
            .customNavigationBar {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
            } rightView: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.template)
                        .foregroundColor(.gray2)
                    TextField("검색어를 입력하세요", text: $text)
                        .foregroundColor(Color(0x646464))
                }
                .frame(width: 312, height: 30)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color(0xf1f1f5))
                .cornerRadius(8)
            }
    }
}

struct LookAroundView_Previews: PreviewProvider {
    static var previews: some View {
        LookAroundView()
    }
}
