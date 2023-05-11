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
        formatter.dateFormat = "M월 d일 EEE"
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

            ListView(checkListViewModel: viewModel) {
                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByFlagWithToday,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01),
                    emptyTextContent: "중요한 할 일이 있나요?"
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    HStack(spacing: 0) {
                        Button {} label: {
                            Image("toggle")
                                .renderingMode(.template)
                                .frame(width: 20, height: 28)
                                .rotationEffect(Angle(degrees: 90))
                        }
                        .padding(.leading, 14)
                        .foregroundColor(Color(0x646464))

                        TagView(
                            tag: Tag(
                                id: DefaultTag.important.rawValue,
                                content: DefaultTag.important.rawValue
                            ),
                            isSelected: true
                        )
                        .padding(.leading, 10)
                    }
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
                    HStack(spacing: 0) {
                        Button {} label: {
                            Image("toggle")
                                .renderingMode(.template)
                                .frame(width: 20, height: 28)
                                .rotationEffect(Angle(degrees: 90))
                        }
                        .padding(.leading, 14)
                        .foregroundColor(Color(0x646464))

                        TagView(
                            tag: Tag(id: "오늘 할 일", content: "오늘 할 일"),
                            isSelected: true
                        )
                        .padding(.leading, 10)
                    }
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
                    HStack(spacing: 0) {
                        Button {} label: {
                            Image("toggle")
                                .renderingMode(.template)
                                .frame(width: 20, height: 28)
                                .rotationEffect(Angle(degrees: 90))
                        }
                        .padding(.leading, 14)
                        .foregroundColor(Color(0x646464))

                        TagView(
                            tag: Tag(id: "오늘까지", content: "오늘까지"),
                            isSelected: true
                        )
                        .padding(.leading, 10)
                    }
                }

                Divider()

                ListSectionView(
                    checkListViewModel: viewModel,
                    todoAddViewModel: addViewModel,
                    todoList: $viewModel.todoListByCompleted,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01),
                    emptyTextContent: "할 일을 완료해 보세요!"
                ) {
                    viewModel.updateOrderHaru()
                } header: {
                    HStack(spacing: 0) {
                        Button {} label: {
                            Image("toggle")
                                .renderingMode(.template)
                                .frame(width: 20, height: 28)
                                .rotationEffect(Angle(degrees: 90))
                        }
                        .padding(.leading, 14)
                        .foregroundColor(Color(0x646464))

                        TagView(
                            tag: Tag(
                                id: DefaultTag.completed.rawValue,
                                content: DefaultTag.completed.rawValue
                            ),
                            isSelected: true
                        )
                        .padding(.leading, 10)
                    }
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
        .onAppear {
            viewModel.mode = .haru
            viewModel.fetchTodoListByTodayTodoAndUntilToday()
        }
        .onDisappear {
            viewModel.mode = .main
        }
    }
}
