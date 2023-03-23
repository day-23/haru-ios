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
    @State private var prevOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true
    @State private var minOffset: CGFloat?
    @State private var maxOffset: CGFloat?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                //  태그 리스트
                TagListView(viewModel: viewModel) { tag in
                    withAnimation {
                        viewModel.selectedTag = tag
                    }
                    prevOffset = nil
                    minOffset = nil
                    maxOffset = nil
                }

                //  오늘 나의 하루
                NavigationLink {
                    HaruView(
                        viewModel: viewModel,
                        addViewModel: addViewModel
                    )
                } label: {
                    HaruLinkView()
                }

                //  체크 리스트
                if !viewModel.isEmpty {
                    if viewModel.selectedTag == nil {
                        ListView {
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
                        } offsetChanged: {
                            self.changeOffset($0)
                        }
                    } else {
                        if let tag = viewModel.selectedTag {
                            if tag.id == "중요" {
                                ListView {
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
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else if tag.id == "미분류" {
                                ListView {
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
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else if tag.id == "완료" {
                                //  FIXME: - 추후에 페이지네이션 함수로 교체 해야함
                                ListView {
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
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else {
                                //  Tag 클릭시
                                ListView {
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
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
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
                    HStack(spacing: 0) {
                        TextField("할 일 간편 추가", text: $addViewModel.todoContent)
                            .font(.system(size: 14, weight: .light))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(0xF1F1F5))
                            .cornerRadius(8)
                            .padding(.leading, 20)
                            .padding(.trailing, 16)
                            .onSubmit {
                                addViewModel.addSimpleTodo()
                            }

                        Button {
                            withAnimation {
                                isModalVisible = true
                                addViewModel.mode = .add
                            }
                        } label: {
                            Image("add-button")
                        }
                    }
                    .zIndex(5)
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

    func changeOffset(_ value: CGFloat?) {
        if self.prevOffset == nil || self.prevOffset == 0 {
            self.viewIsShown = true
            self.prevOffset = value
            self.minOffset = value
            self.maxOffset = value
            return
        }
        self.offset = value

        guard let prevOffset = self.prevOffset,
              let offset = self.offset,
              let minOffset = self.minOffset,
              let maxOffset = self.maxOffset
        else {
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
//            if maxOffset - offset < UIScreen.main.bounds.height {
//                self.viewIsShown = true
//            } else if offset < minOffset + 200 {
//                self.viewIsShown = false
//            } else {}

            if prevOffset > offset {
                self.viewIsShown = false
            } else {
                self.viewIsShown = true
            }
            self.prevOffset = offset
        }
        self.minOffset = min(minOffset, offset)
        self.maxOffset = max(maxOffset, offset)
    }
}
