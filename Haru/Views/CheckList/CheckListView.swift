//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct CheckListView: View {
    @EnvironmentObject var todoState: TodoState
    @StateObject var viewModel: CheckListViewModel
    @StateObject var addViewModel: TodoAddViewModel
    @State private var isModalVisible: Bool = false
    @State private var prevOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        let isTagManageModalVisible: Binding<Bool> = .init {
            Global.shared.isFaded
        } set: {
            Global.shared.isFaded = $0
        }

        return ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HaruHeader(isIconGradation: true) {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                } item: {
                    NavigationLink {
                        // TODO: 검색 뷰 만들어지면 넣어주기
                        Text("검색")
                    } label: {
                        Image("magnifyingglass")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                }

                HStack(spacing: 0) {
                    // 태그 리스트
                    TagListView(viewModel: viewModel) { tag in
                        withAnimation {
                            if let selectedTag = viewModel.selectedTag,
                               selectedTag == tag
                            {
                                viewModel.selectedTag = nil
                                prevOffset = nil
                            } else {
                                viewModel.selectedTag = tag
                                prevOffset = nil
                            }
                        }
                    }

                    // 태그 설정창
                    Image("option-button")
                        .frame(width: 28, height: 28)
                        .onTapGesture {
                            withAnimation {
                                isTagManageModalVisible.wrappedValue = true
                            }
                        }
                }
                .padding(.bottom, 10)
                .padding(.trailing, 20)

                // 오늘 나의 하루
                NavigationLink {
                    HaruView(
                        viewModel: viewModel,
                        addViewModel: addViewModel
                    )
                } label: {
                    HaruLinkView()
                }
                .padding(.bottom, 12)

                // 체크 리스트
                if !viewModel.isEmpty {
                    if viewModel.selectedTag == nil {
                        ListView(checkListViewModel: viewModel) {
                            ListSectionView(
                                checkListViewModel: viewModel,
                                todoAddViewModel: addViewModel,
                                todoList: $todoState.todoListByFlag,
                                emptyTextContent: "중요한 할 일이 있나요?"
                            ) {
                                todoState.updateOrderMain()
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
                                checkListViewModel: viewModel,
                                todoAddViewModel: addViewModel,
                                todoList: $todoState.todoListWithAnyTag
                            ) {
                                todoState.updateOrderMain()
                            } header: {
                                TagView(
                                    tag: Tag(
                                        id: DefaultTag.classified.rawValue,
                                        content: DefaultTag.classified.rawValue
                                    ),
                                    isSelected: true,
                                    disabled: todoState.todoListWithAnyTag.isEmpty
                                )
                                .padding(.leading, 10)
                            }

                            Divider()

                            ListSectionView(
                                checkListViewModel: viewModel,
                                todoAddViewModel: addViewModel,
                                todoList: $todoState.todoListWithoutTag
                            ) {
                                todoState.updateOrderMain()
                            } header: {
                                TagView(
                                    tag: Tag(
                                        id: DefaultTag.unclassified.rawValue,
                                        content: DefaultTag.unclassified.rawValue
                                    ),
                                    isSelected: true,
                                    disabled: todoState.todoListWithoutTag.isEmpty
                                )
                                .padding(.leading, 10)
                            }

                            Divider()

                            ListSectionView(
                                checkListViewModel: viewModel,
                                todoAddViewModel: addViewModel,
                                todoList: $todoState.todoListByCompleted,
                                emptyTextContent: "할 일을 완료해 보세요!"
                            ) {
                                todoState.updateOrderMain()
                            } header: {
                                TagView(
                                    tag: Tag(
                                        id: DefaultTag.completed.rawValue,
                                        content: DefaultTag.completed.rawValue
                                    ),
                                    isSelected: true,
                                    disabled: todoState.todoListByCompleted.isEmpty
                                )
                                .padding(.leading, 10)
                            }
                        } offsetChanged: {
                            changeOffset($0)
                        }
                    } else {
                        if let tag = viewModel.selectedTag {
                            if tag.id == DefaultTag.important.rawValue {
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $todoState.todoListByFlag
                                    ) {
                                        todoState.updateOrderFlag()
                                    } header: {
                                        HStack(spacing: 0) {
                                            TagView(
                                                tag: tag,
                                                isSelected: true
                                            )

                                            Spacer()

                                            StarButton(isClicked: true)
                                                .padding(.trailing, 10)
                                        }
                                        .padding(.leading, 10)
                                    }
                                } offsetChanged: {
                                    changeOffset($0)
                                }
                            } else if tag.id == DefaultTag.unclassified.rawValue {
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $todoState.todoListWithoutTag
                                    ) {
                                        todoState.updateOrderWithoutTag()
                                    } header: {
                                        TagView(
                                            tag: tag,
                                            isSelected: true,
                                            disabled: todoState.todoListWithoutTag.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }
                                } offsetChanged: {
                                    changeOffset($0)
                                }
                            } else if tag.id == DefaultTag.completed.rawValue {
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $todoState.todoListByCompleted,
                                        emptyTextContent: "할 일을 완료해 보세요!"
                                    ) {
                                        todoState.updateOrderWithoutTag()
                                    } header: {
                                        TagView(
                                            tag: tag,
                                            isSelected: true,
                                            disabled: todoState.todoListByCompleted.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }
                                } offsetChanged: {
                                    changeOffset($0)
                                }
                            } else {
                                // Tag 클릭시
                                ListView(checkListViewModel: viewModel) {
                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $todoState.todoListByFlag,
                                        emptyTextContent: "중요한 할 일이 있나요?"
                                    ) {
                                        todoState.updateOrderByTag(tagId: tag.id)
                                    } header: {
                                        TagView(
                                            tag: Tag(
                                                id: DefaultTag.important.rawValue,
                                                content: DefaultTag.important.rawValue
                                            ),
                                            isSelected: true,
                                            disabled: todoState.todoListByFlag.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }

                                    Divider()

                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $todoState.todoListByTag
                                    ) {
                                        todoState.updateOrderByTag(tagId: tag.id)
                                    } header: {
                                        TagView(
                                            tag: tag,
                                            isSelected: true,
                                            disabled: todoState.todoListByTag.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }

                                    Divider()

                                    ListSectionView(
                                        checkListViewModel: viewModel,
                                        todoAddViewModel: addViewModel,
                                        todoList: $todoState.todoListByCompleted,
                                        emptyTextContent: "할 일을 완료해 보세요!"
                                    ) {
                                        todoState.updateOrderByTag(tagId: tag.id)
                                    } header: {
                                        TagView(
                                            tag: Tag(
                                                id: DefaultTag.completed.rawValue,
                                                content: DefaultTag.completed.rawValue
                                            ),
                                            isSelected: true,
                                            disabled: todoState.todoListByCompleted.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }

                                } offsetChanged: {
                                    changeOffset($0)
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
            .background(.white)

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
            } else if isTagManageModalVisible.wrappedValue {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            isTagManageModalVisible.wrappedValue = false
                        }
                    }

                TagManageView(
                    checkListViewModel: viewModel,
                    isActive: isTagManageModalVisible
                )
                .position(
                    x: UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.78 + (UIScreen.main.bounds.width * 0.78 * 0.5),
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
                                .font(.pretendard(size: 14, weight: .regular))
                                .foregroundColor(Color(0x646464))
                        }
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(Color(0x646464))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color(0xf1f1f5))
                        .cornerRadius(8)
                        .padding(.trailing, 18)
                        .padding(.bottom, 4)
                        .focused($isTextFieldFocused)
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
            isTagManageModalVisible.wrappedValue = false
            viewModel.selectedTag = nil
            viewModel.fetchTodoList()
            viewModel.fetchTags()
            UIApplication.shared.addTapGestureRecognizer()
        }
        .onChange(of: isTextFieldFocused, perform: { value in
            if isModalVisible {
                return
            }

            withAnimation {
                Global.shared.isTabViewActive = !value
            }
        })
        .contentShape(Rectangle())
    }

    func changeOffset(_ value: CGPoint?) {
        if self.prevOffset == nil {
            viewIsShown = true
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
                viewIsShown = true
            } else if prevOffset > offset {
                viewIsShown = false
            } else {
                viewIsShown = true
            }
            self.prevOffset = offset
        }
    }
}
