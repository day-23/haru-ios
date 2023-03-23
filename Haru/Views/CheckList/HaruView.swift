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

            ListView {
                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByFlagWithToday
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    StarButton(isClicked: true)
                        .padding(.leading, 29)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByTodayTodo
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    TagView(Tag(id: "오늘 할 일", content: "오늘 할 일"))
                        .padding(.leading, 21)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByUntilToday
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    TagView(Tag(id: "오늘까지", content: "오늘까지"))
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
//        .toolbarBackground(.hidden)
    }
}
