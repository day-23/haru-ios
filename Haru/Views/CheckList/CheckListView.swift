//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct CheckListView: View {
    @StateObject var viewModel: CheckListViewModel
    @StateObject var addViewModel: TodoAddViewModel
    @State private var isModalVisible: Bool = false
    @State private var isTagManageModalVisible: Bool = false
    @State private var prevOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    //  태그 리스트
                    TagListView(viewModel: viewModel) { tag in
                        withAnimation {
                            viewModel.selectedTag = tag
                            prevOffset = nil
                        }
                    }

                    //  태그 설정창
                    Image("option-button")
                        .frame(width: 28, height: 28)
                        .onTapGesture {
                            withAnimation {
                                isTagManageModalVisible = true
                            }
                        }
                }
                .padding(.bottom, 10)
                .padding(.trailing, 20)

                //  오늘 나의 하루
                NavigationLink {
                    HaruView(
                        viewModel: viewModel,
                        addViewModel: addViewModel
                    )
                } label: {
                    HaruLinkView()
                }
                .padding(.bottom, 12)

                //  체크 리스트
                if !viewModel.isEmpty {
                    if viewModel.selectedTag == nil {
                        ListView(checkListViewModel: viewModel) {
                            ListSectionView(
                                checkListViewModel: viewModel,
                                todoAddViewModel: addViewModel,
                                todoList: $viewModel.todoListByFlag
                            ) {
                                viewModel.updateOrderMain()
                            } header: {
                                TagView(tag: Tag(id: DefaultTag.important.rawValue, content: DefaultTag.important.rawValue))
                                    .padding(.leading, 21)
                            }

                            Divider()

                            ListSectionView(
                                checkListViewModel: viewModel,
                                todoAddViewModel: addViewModel,
                                todoList: $viewModel.todoListWithAnyTag
                            ) {
                                viewModel.updateOrderMain()
                            } header: {
                                TagView(tag: Tag(id: DefaultTag.classified.rawValue, content: DefaultTag.classified.rawValue))
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
                                TagView(tag: Tag(id: DefaultTag.unclassified.rawValue, content: DefaultTag.unclassified.rawValue))
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
                                TagView(tag: Tag(id: DefaultTag.completed.rawValue, content: DefaultTag.completed.rawValue))
                                    .padding(.leading, 21)
                            }
                        } offsetChanged: {
                            self.changeOffset($0)
                        }
                    } else {
                        if let tag = viewModel.selectedTag {
                            if tag.id == DefaultTag.completed.rawValue {
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $viewModel.todoListByFlag
                                    ) {
                                        viewModel.updateOrderFlag()
                                    } header: {
                                        TagView(tag: tag,
                                                isSelected: viewModel.selectedTag?.id == DefaultTag.completed.rawValue)
                                            .padding(.leading, 21)
                                    }
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else if tag.id == DefaultTag.unclassified.rawValue {
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $viewModel.todoListWithoutTag
                                    ) {
                                        viewModel.updateOrderWithoutTag()
                                    } header: {
                                        TagView(tag: tag,
                                                isSelected: viewModel.selectedTag?.id == DefaultTag.unclassified.rawValue)
                                            .padding(.leading, 21)
                                    }
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else if tag.id == DefaultTag.completed.rawValue {
                                //  FIXME: - 추후에 페이지네이션 함수로 교체 해야함
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $viewModel.todoListByCompleted
                                    ) {
                                        viewModel.updateOrderWithoutTag()
                                    } header: {
                                        TagView(tag: tag,
                                                isSelected: viewModel.selectedTag?.id == DefaultTag.completed.rawValue)
                                            .padding(.leading, 21)
                                    }
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else {
                                //  Tag 클릭시
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $viewModel.todoListByTag
                                    ) {
                                        viewModel.updateOrderByTag(tagId: tag.id)
                                    } header: {
                                        TagView(tag: tag,
                                                isSelected: viewModel.selectedTag?.id == tag.id)
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
            } else if isTagManageModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            isTagManageModalVisible = false
                        }
                    }

                TagOptionView(
                    checkListViewModel: viewModel,
                    isActive: $isTagManageModalVisible
                )
                .position(
                    x: UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.915 + (UIScreen.main.bounds.width * 0.915 * 0.5),
                    y: UIScreen.main.bounds.height * 0.4
                )
                .zIndex(2)
                .transition(
                    .asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading))
                )

            } else if viewIsShown {
                HStack(alignment: .bottom, spacing: 0) {
                    TextField("", text: $addViewModel.content)
                        .placeholder(when: addViewModel.content.isEmpty) {
                            Text("간편 추가")
                                .foregroundColor(Color(0x646464))
                        }
                        .font(.pretendard(size: 14, weight: .medium))
                        .foregroundColor(Color(0x646464))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color(0xf1f1f5))
                        .cornerRadius(8)
                        .padding(.trailing, 18)
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
                            .shadow(radius: 10, x: 5, y: 0)
                    }
                }
                .zIndex(5)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            isModalVisible = false
            isTagManageModalVisible = false
            viewModel.selectedTag = nil
            viewModel.fetchTodoList()
            viewModel.fetchTags()
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
