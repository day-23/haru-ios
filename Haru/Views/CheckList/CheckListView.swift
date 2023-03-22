//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI
import UniformTypeIdentifiers

struct CheckListView: View {
    @StateObject var viewModel: CheckListViewModel
    @StateObject var addViewModel: TodoAddViewModel
    @State private var isModalVisible: Bool = false
    @State private var initialOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    //  태그 리스트
                    TagList(viewModel: viewModel) { tag in
                        withAnimation {
                            viewModel.selectedTag = tag
                        }
                        initialOffset = nil
                    }

                    //  오늘 나의 하루 클릭시
                    HStack {
                        Image("today-todo")
                            .padding(.vertical, 12)
                            .padding(.leading, 20)
                            .padding(.trailing, 12)
                            .tint(.white)
                        Text("오늘 나의 하루")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .frame(width: 28, height: 28)
                            .padding(.trailing, 20)
                    }
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF), Color(0xAAD7FF)]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedTag = Tag(id: "하루", content: "하루")
                        }
                        initialOffset = nil
                    }

                    //  체크 리스트
                    if !viewModel.isEmpty {
                        List {
                            if viewModel.selectedTag == nil {
                                ListSectionView(
                                    checkListViewModel: viewModel,
                                    todoAddViewModel: addViewModel,
                                    todoList: $viewModel.todoListByFlag
                                ) {
                                    viewModel.updateOrderMain()
                                } header: {
                                    StarButton(isClicked: true)
                                        .padding(.leading, 29)
                                }

                                Divider()
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())

                                ListSectionView(
                                    checkListViewModel: viewModel,
                                    todoAddViewModel: addViewModel,
                                    todoList: $viewModel.todoListWithAnyTag
                                ) {
                                    viewModel.updateOrderMain()
                                } header: {
                                    TagView(Tag(id: "분류됨", content: "분류됨"))
                                        .padding(.leading, 21)
                                }

                                Divider()
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())

                                ListSectionView(
                                    checkListViewModel: viewModel,
                                    todoAddViewModel: addViewModel,
                                    todoList: $viewModel.todoListWithoutTag
                                ) {
                                    viewModel.updateOrderMain()
                                } header: {
                                    TagView(Tag(id: "미분류", content: "미분류"))
                                        .padding(.leading, 21)
                                }

                                Divider()
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())

                                ListSectionView(
                                    checkListViewModel: viewModel,
                                    todoAddViewModel: addViewModel,
                                    todoList: $viewModel.todoListByCompleted
                                ) {
                                    viewModel.updateOrderMain()
                                } header: {
                                    TagView(Tag(id: "완료", content: "완료"))
                                        .padding(.leading, 21)
                                }
                            } else {
                                if let tag = viewModel.selectedTag {
                                    if tag.id == "하루" {
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
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets())

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
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets())

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
                                    } else if tag.id == "중요" {
                                        ListSectionView(
                                            checkListViewModel: viewModel,
                                            todoAddViewModel: addViewModel,
                                            todoList: $viewModel.todoListByFlag
                                        ) {
                                            viewModel.updateOrderFlag()
                                        } header: {
                                            StarButton(isClicked: true)
                                                .padding(.leading, 29)
                                        }
                                    } else if tag.id == "미분류" {
                                        ListSectionView(
                                            checkListViewModel: viewModel,
                                            todoAddViewModel: addViewModel,
                                            todoList: $viewModel.todoListWithoutTag
                                        ) {
                                            viewModel.updateOrderWithoutTag()
                                        } header: {
                                            TagView(tag)
                                                .padding(.leading, 21)
                                        }
                                    } else if tag.id == "완료" {
                                        //  FIXME: - 추후에 페이지네이션 함수로 교체 해야함
                                        ListSectionView(
                                            checkListViewModel: viewModel,
                                            todoAddViewModel: addViewModel,
                                            todoList: $viewModel.todoListByCompleted
                                        ) {
                                            viewModel.updateOrderWithoutTag()
                                        } header: {
                                            TagView(tag)
                                                .padding(.leading, 21)
                                        }
                                    } else {
                                        ListSectionView(
                                            checkListViewModel: viewModel,
                                            todoAddViewModel: addViewModel,
                                            todoList: $viewModel.todoListByTag
                                        ) {
                                            viewModel.updateOrderByTag(tagId: tag.id)
                                        } header: {
                                            TagView(tag)
                                                .padding(.leading, 21)
                                        }
                                    }
                                }
                            }

                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: OffsetKey.self,
                                    value: geometry.frame(in: .global).minY
                                )
                                .frame(height: 0)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .environment(\.defaultMinListRowHeight, 48)
                        .listStyle(.inset)
                        .onPreferenceChange(OffsetKey.self) {
                            if self.initialOffset == nil || self.initialOffset == 0 {
                                self.viewIsShown = true
                                self.initialOffset = $0
                                return
                            }
                            self.offset = $0

                            guard let initialOffset = self.initialOffset,
                                  let offset = self.offset
                            else {
                                return
                            }

                            withAnimation(.easeInOut(duration: 0.25)) {
                                if initialOffset > offset {
                                    self.viewIsShown = false
                                } else {
                                    self.viewIsShown = true
                                }
                            }
                        }
                    } else {
                        VStack {
                            Text("모든 할 일을 마쳤습니다!")
                                .foregroundColor(Color(0x000000, opacity: 0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

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
                } else {
                    if viewIsShown {
                        Button {
                            withAnimation {
                                isModalVisible = true
                                addViewModel.mode = .add
                            }
                        } label: {
                            Image("add-button")
                        }
                        .zIndex(5)
                    }
                }
            }
        }
        .onAppear {
            isModalVisible = false
            viewModel.selectedTag = nil
            viewModel.fetchTodoList()
            viewModel.fetchTags()
        }
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}
