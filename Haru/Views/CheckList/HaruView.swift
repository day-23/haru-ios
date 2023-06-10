//
//  HaruView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct HaruView: View {
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var todoState: TodoState
    @StateObject var viewModel: CheckListViewModel
    @StateObject var addViewModel: TodoAddViewModel
    @State private var isModalVisible: Bool = false
    @State private var prevOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true

    let formatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "MMMM d\(Locale.current.language.languageCode?.identifier == "ko" ? "일" : "") EEEE"
        return formatter
    }()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("background-haru")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            ListView(checkListViewModel: self.viewModel) {
                ListSectionView(
                    checkListViewModel: self.viewModel,
                    todoAddViewModel: self.addViewModel,
                    todoList: self.$todoState.todoListByFlagWithToday,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01),
                    emptyTextContent: "중요한 할 일이 있나요?"
                ) {
                    self.todoState.updateOrderHaru()
                } header: {
                    HStack(spacing: 0) {
                        TagView(
                            tag: Tag(
                                id: DefaultTag.important.rawValue,
                                content: DefaultTag.important.rawValue
                            ),
                            isSelected: true
                        )

                        Spacer()

                        StarButton(isClicked: true)
                            .padding(.trailing, 10)
                    }
                    .padding(.leading, 10)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: self.viewModel,
                    todoAddViewModel: self.addViewModel,
                    todoList: self.$todoState.todoListByTodayTodo,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01)
                ) {
                    self.todoState.updateOrderHaru()
                } header: {
                    TagView(
                        tag: Tag(id: "오늘 할 일", content: "오늘 할 일"),
                        isSelected: true,
                        disabled: self.todoState.todoListByTodayTodo.isEmpty
                    )
                    .padding(.leading, 10)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: self.viewModel,
                    todoAddViewModel: self.addViewModel,
                    todoList: self.$todoState.todoListByUntilToday,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01)
                ) {
                    self.todoState.updateOrderHaru()
                } header: {
                    TagView(
                        tag: Tag(id: "오늘까지", content: "오늘까지"),
                        isSelected: true,
                        disabled: self.todoState.todoListByUntilToday.isEmpty
                    )
                    .padding(.leading, 10)
                }

                Divider()

                ListSectionView(
                    checkListViewModel: self.viewModel,
                    todoAddViewModel: self.addViewModel,
                    todoList: self.$todoState.todoListByCompleted,
                    itemBackgroundColor: Color(0xFFFFFF, opacity: 0.01),
                    emptyTextContent: "할 일을 완료해 보세요!"
                ) {
                    self.todoState.updateOrderHaru()
                } header: {
                    TagView(
                        tag: Tag(
                            id: DefaultTag.completed.rawValue,
                            content: DefaultTag.completed.rawValue
                        ),
                        isSelected: true,
                        disabled: self.todoState.todoListByCompleted.isEmpty
                    )
                    .padding(.leading, 10)
                }
            } offsetChanged: { self.changeOffset($0) }

            if self.isModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.isModalVisible = false
                        }
                    }

                Modal(isActive: self.$isModalVisible, ratio: 0.9) {
                    TodoAddView(
                        viewModel: self.addViewModel,
                        isModalVisible: self.$isModalVisible
                    )
                }
                .transition(.modal)
                .zIndex(2)
            } else if self.viewIsShown {
                HStack(alignment: .bottom, spacing: 0) {
                    TextField("", text: self.$addViewModel.content)
                        .placeholder(when: self.addViewModel.content.isEmpty) {
                            Text("오늘 할 일 빠른 추가")
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
                            self.addViewModel.addSimpleTodo()
                        }

                    Button {
                        withAnimation {
                            self.isModalVisible = true
                            self.addViewModel.mode = .add
                            self.addViewModel.isTodayTodo = true
                            self.addViewModel.isSelectedEndDate = true
                        }
                    } label: {
                        Image("add-button")
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
                Image("back-button")
                    .frame(width: 28, height: 28)
                    .padding(.leading, 5)
                    .onTapGesture {
                        self.dismissAction.callAsFunction()
                    }
            }

            ToolbarItem(placement: .principal) {
                Text(self.formatter.string(from: .now))
                    .font(.system(size: 20, weight: .bold))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    // TODO: 검색 뷰 만들어지면 넣어주기
                    Text("검색")
                } label: {
                    Image("search")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(Color(0x191919))
                        .frame(width: 28, height: 28)
                }
                .padding(.trailing, 5)
            }
        }
        .toolbarBackground(Color(0xD9EAFD))
        .onAppear {
            self.viewModel.mode = .haru
            self.todoState.fetchTodoListByTodayTodoAndUntilToday()
        }
        .onDisappear {
            self.viewModel.mode = .main
        }
        .contentShape(Rectangle())
        .gesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
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
