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
    @State private var isModalVisible: Bool = false
    @State private var prevOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true

    let formatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "M월 d일 EEE"
        return formatter
    }()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    TagView(
                        tag: Tag(
                            id: DefaultTag.important.rawValue,
                            content: DefaultTag.important.rawValue
                        ),
                        isSelected: true
                    )
                    .padding(.leading, 10)
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
                    .padding(.leading, 10)
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
                    .padding(.leading, 10)
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
                    TagView(
                        tag: Tag(
                            id: DefaultTag.completed.rawValue,
                            content: DefaultTag.completed.rawValue
                        ),
                        isSelected: true
                    )
                    .padding(.leading, 10)
                }
            } offsetChanged: { changeOffset($0) }

            if isModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            isModalVisible = false
                        }
                    }

                Modal(isActive: $isModalVisible, ratio: 0.9) {
                    TodoAddView(
                        viewModel: addViewModel,
                        isModalVisible: $isModalVisible
                    )
                }
                .transition(.modal)
                .zIndex(2)
            } else if viewIsShown {
                HStack(alignment: .bottom, spacing: 0) {
                    TextField("", text: $addViewModel.content)
                        .placeholder(when: addViewModel.content.isEmpty) {
                            Text("간편 추가")
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(Color(0x646464))
                        }
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color(0xF1F1F5))
                        .cornerRadius(8)
                        .padding(.trailing, 18)
                        .padding(.bottom, 4)
                        .onSubmit {
                            addViewModel.addSimpleTodo()
                        }

                    Button {
                        withAnimation {
                            isModalVisible = true
                            addViewModel.mode = .add
                            addViewModel.isTodayTodo = true
                            addViewModel.isSelectedEndDate = true
                        }
                    } label: {
                        Image("add-button")
                            .shadow(radius: 10, x: 5, y: 0)
                    }
                }
                .zIndex(5)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
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

    func changeOffset(_ value: CGPoint?) {
        if self.prevOffset == nil {
            self.viewIsShown = true
            self.prevOffset = value?.y
            return
        }
        self.offset = value?.y

        guard let prevOffset,
              let offset
        else {
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            if offset >= 0 {
                self.viewIsShown = true
            } else if prevOffset > offset {
                self.viewIsShown = false
            } else {
                self.viewIsShown = true
            }
            self.prevOffset = offset
        }
    }
}
