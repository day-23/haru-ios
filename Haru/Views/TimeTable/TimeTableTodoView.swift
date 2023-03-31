//
//  TimeTableTodoView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import SwiftUI

struct TimeTableTodoView: View {
    var body: some View {
        VStack(spacing: 0) {
            TimeTableTodoRow()
            TimeTableTodoRow()
            TimeTableTodoRow()
            TimeTableTodoRow()
            TimeTableTodoRow()
            TimeTableTodoRow()
            TimeTableTodoRow()

            Spacer()
        }
    }
}

struct TimeTableTodoRow: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("일")
                    .font(.pretendard(size: 14, weight: .bold))
                    .padding(.top, 12)
                    .padding(.bottom, 7)
                Text("10")
                    .font(.pretendard(size: 14, weight: .bold))
            }
            .padding(.trailing, 24)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    TimeTableTodoItem()
                    TimeTableTodoItem()
                    TimeTableTodoItem()
                    TimeTableTodoItem()
                }
                .padding(1)
            }
        }
        .frame(width: 336, height: 74)
        .padding(.leading, 24)
        .padding(.trailing, 30)
    }
}

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
        .frame(width: 64, height: 58)
        .background(Color(0xFDFDFD))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]), lineWidth: 2)
        )
    }
}

struct TimeTableTodoView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableTodoView()
    }
}
