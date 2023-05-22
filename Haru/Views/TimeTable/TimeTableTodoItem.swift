//
//  TimeTableTodoItem.swift
//  Haru
//
//  Created by 최정민 on 2023/04/07.
//

import SwiftUI

struct TimeTableTodoItem: View {
    var todo: TodoCell

    var body: some View {
        ZStack {
            Text(todo.data.content)
                .font(.pretendard(size: 16, weight: .bold))
                .foregroundColor(Color(0x191919))
                .background(.clear)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .cornerRadius(8)
        }
        .frame(width: 64, height: 58)
        .background(Color(0xFDFDFD))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]), lineWidth: 2)
        )
    }
}
