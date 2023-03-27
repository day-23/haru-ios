//
//  HaruView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct HaruView: View {
    @Environment(\.dismiss) var dismissAction
    @StateObject var viewModel: CheckListViewModel
    @StateObject var addViewModel: TodoAddViewModel

    let formatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "M월 d일 EEE요일"
        return formatter
    }()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF), Color(0xAAD7FF)]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            ).ignoresSafeArea()
                .opacity(0.5)

            ListView {
                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByFlagWithToday,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01)
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    HStack(spacing: 0) {
                        StarButton(isClicked: true)
                        Text("중요")
                            .font(.pretendard(size: 14, weight: .bold))
                            .padding(.leading, 6)
                    }
                    .padding(.leading, 29)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByTodayTodo,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01)
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    TagView(
                        tag: Tag(id: "오늘 할 일", content: "오늘 할 일"),
                        isSelected: true
                    )
                    .padding(.leading, 21)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByUntilToday,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01)
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    TagView(
                        tag: Tag(id: "오늘까지", content: "오늘까지"),
                        isSelected: true
                    )
                    .padding(.leading, 21)
                }
            } offsetChanged: { _ in }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Image("back-button")
                            .frame(width: 28, height: 28)
                    }

                    Text(formatter.string(from: .now))
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        .toolbarBackground(Color(0xD9EAFD))
    }
}
