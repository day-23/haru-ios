//
//  TimeTableTodoRow.swift
//  Haru
//
//  Created by 최정민 on 2023/04/07.
//

import SwiftUI

struct TimeTableTodoRow: View {
    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    var index: Int
    var date: Date
    @Binding var todoList: [Todo]
    @StateObject var timeTableViewModel: TimeTableViewModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(week[index])
                    .font(.pretendard(size: 14, weight: .bold))
                    .foregroundColor(
                        index == 0 ? Color(0xF71E58) : index == 6 ? Color(0x1DAFFF) : Color(0x191919)
                    )
                    .padding(.bottom, 7)

                if index == Date.now.indexOfWeek() {
                    Text("\(date.day)")
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(Color(0x2CA4FF))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            Circle()
                                .stroke(.gradation1, lineWidth: 2)
                        )
                } else {
                    Text("\(date.day)")
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(
                            index == 0 ? Color(0xF71E58) : index == 6 ? Color(0x1DAFFF) : Color(0x191919)
                        )
                        .padding(.horizontal, 6)
                }
            }
            .padding(.trailing, 24)

            if todoList.isEmpty {
                EmptySectionView()
                    .padding(1)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(todoList) { todo in
                            TimeTableTodoItem(
                                todo: todo
                            )
                            .transition(.scale)
                            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 10))
                            .onDrag {
                                timeTableViewModel.draggingTodo = todo
                                return NSItemProvider(object: todo.id as NSString)
                            }
                        }
                    }
                    .padding(1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 72)
        .padding(.leading, 24)
    }
}
