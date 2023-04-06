//
//  TimeTableTodoItem.swift
//  Haru
//
//  Created by 최정민 on 2023/04/07.
//

import SwiftUI

struct TimeTableTodoItem: View {
    var body: some View {
        ZStack {
            Text("가나다라마바")
                .font(.pretendard(size: 16, weight: .regular))
                .padding([.top, .leading, .trailing], 10)
                .padding(.bottom, 4)
                .background(Color(0xFDFDFD))
                .cornerRadius(8)
        }
        .frame(width: 68, height: 62)
        .background(Color(0xFDFDFD))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]), lineWidth: 2)
        )
    }
}
