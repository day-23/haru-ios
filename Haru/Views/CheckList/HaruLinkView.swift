//
//  HaruLinkView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct HaruLinkView: View {
    var body: some View {
        HStack {
            Image("today-todo")
                .renderingMode(.template)
                .padding(.vertical, 12)
                .padding(.leading, 20)
                .padding(.trailing, 12)
                .tint(.white)
            Text("오늘 나의 하루")
                .font(.pretendard(size: 20, weight: .bold))
            Spacer()
            Image(systemName: "chevron.right")
                .frame(width: 28, height: 28)
                .padding(.trailing, 20)
        }
        .frame(height: 52)
        .foregroundColor(.white)
        .background(
            RadialGradient(
                colors: [
                    Color(0xAAD7FF),
                    Color(0xD2D7FF)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
        )
    }
}
