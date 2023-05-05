//
//  PostFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/04.
//

import SwiftUI

struct PostFormView: View {
    @Environment(\.dismiss) var dismissAction
    
    @State var text: String = ""
    
    var body: some View {
        TextField("텍스트를 입력해주세요.", text: $text)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .customNavigationBar {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("cancel")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            } rightView: {
                HStack(spacing: 10) {
                    Text("하루 쓰기")
                        .font(.pretendard(size: 20, weight: .bold))
                    Image("toggle")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }
    }
}

struct PostFormView_Previews: PreviewProvider {
    static var previews: some View {
        PostFormView()
    }
}
