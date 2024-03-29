//
//  TimeTableTodoRow.swift
//  Haru
//
//  Created by 최정민 on 2023/04/07.
//

import SwiftUI

struct TimeTableTodoRow: View {
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    var index: Int
    var date: Date
    @Binding var todoList: [TodoCell]
    @StateObject var timeTableViewModel: TimeTableViewModel
    @StateObject var todoAddViewModel: TodoAddViewModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(week[index])
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(
                        index == 0
                            ? Color(0xf71e58)
                            : (index == 6
                                ? Color(0x1dafff)
                                : Color(0x646464)
                            )
                    )
                    .padding(.bottom, 7)

                if dateFormatter.string(from: date) == dateFormatter.string(from: .now) {
                    Image("time-table-date-circle")
                        .overlay {
                            Text("\(date.day)")
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(Color(0x2ca4ff))
                        }
                } else {
                    Text("\(date.day)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(
                            timeTableViewModel.thisWeek[index].month != timeTableViewModel.currentMonth
                                ? (index == 0
                                    ? Color(0xfdbbcd)
                                    : (index == 6
                                        ? Color(0xbbe7ff)
                                        : Color(0xebebeb)
                                    )
                                )
                                : (index == 0
                                    ? Color(0xf71e58)
                                    : (index == 6
                                        ? Color(0x1dafff)
                                        : Color(0x646464)
                                    )
                                )
                        )
                }
            }
            .frame(width: 20)
            .padding(.leading, 24)
            .padding(.trailing, 20)

            if todoList.isEmpty {
                EmptySectionView()
                    .padding(1)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UIDevice.current.name.contains("SE") ? 8 : 10) {
                        ForEach(todoList) { todo in
                            NavigationLink {
                                TodoAddView(
                                    viewModel: todoAddViewModel
                                )
                                .onAppear {
                                    todoAddViewModel.applyTodoData(
                                        todo: todo.data,
                                        at: todo.at
                                    )
                                }
                            } label: {
                                TimeTableTodoItem(todo: todo)
                                    .transition(.scale)
                                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 10))
                                    .onDrag {
                                        HapticManager.instance.impact(style: .heavy)
                                        timeTableViewModel.draggingTodo = todo
                                        return NSItemProvider(object: todo.data.id as NSString)
                                    }
                            }
                        }
                    }
                    .padding(1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: UIDevice.current.name.contains("SE") ? 72 : 76)
    }
}
