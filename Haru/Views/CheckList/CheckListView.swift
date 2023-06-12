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
                HaruHeader {
                    HStack(spacing: 10) {
                        NavigationLink {
                            ProductivitySearchView(
                                calendarVM: CalendarViewModel(),
                                todoAddViewModel: self.addViewModel,
                                checkListVM: self.viewModel
                            )
                        } label: {
                            Image("search")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(Color(0x191919))
                                .frame(width: 28, height: 28)
                        }

                        // 태그 설정창
                        Image("slider")
                            .frame(width: 28, height: 28)
                            .onTapGesture {
                                withAnimation {
                                    isTagManageModalVisible.wrappedValue = true
                                }
                            }
                    }
                }

                // 태그 리스트
                TagListView(viewModel: self.viewModel) { tag in
                    withAnimation {
                        if let selectedTag = viewModel.selectedTag,
                           selectedTag == tag
                        {
                            self.viewModel.selectedTag = nil
                            self.prevOffset = nil
                        } else {
                            self.viewModel.selectedTag = tag
                            self.prevOffset = nil
                        }
                    }
                }
                .padding(.bottom, 10)

                // 오늘 나의 하루
                NavigationLink {
                    HaruView(
                        viewModel: self.viewModel,
                        addViewModel: self.addViewModel
                    )
                } label: {
                    HaruLinkView()
                }

                // 체크 리스트
                if !self.viewModel.isEmpty {
                    if self.viewModel.selectedTag == nil {
                        ListView(checkListViewModel: self.viewModel) {
                            ListSectionView(
                                checkListViewModel: self.viewModel,
                                todoAddViewModel: self.addViewModel,
                                todoList: self.$todoState.todoListByFlag,
                                emptyTextContent: "중요한 할 일이 있나요?"
                            ) {
                                self.todoState.updateOrderMain()
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
                                todoList: self.$todoState.todoListWithAnyTag
                            ) {
                                self.todoState.updateOrderMain()
                            } header: {
                                TagView(
                                    tag: Tag(
                                        id: DefaultTag.classified.rawValue,
                                        content: DefaultTag.classified.rawValue
                                    ),
                                    isSelected: true,
                                    disabled: self.todoState.todoListWithAnyTag.isEmpty
                                )
                                .padding(.leading, 10)
                            }

                            Divider()

                            ListSectionView(
                                checkListViewModel: self.viewModel,
                                todoAddViewModel: self.addViewModel,
                                todoList: self.$todoState.todoListWithoutTag
                            ) {
                                self.todoState.updateOrderMain()
                            } header: {
                                TagView(
                                    tag: Tag(
                                        id: DefaultTag.unclassified.rawValue,
                                        content: DefaultTag.unclassified.rawValue
                                    ),
                                    isSelected: true,
                                    disabled: self.todoState.todoListWithoutTag.isEmpty
                                )
                                .padding(.leading, 10)
                            }

                            Divider()

                            ListSectionView(
                                checkListViewModel: self.viewModel,
                                todoAddViewModel: self.addViewModel,
                                todoList: self.$todoState.todoListByCompleted,
                                emptyTextContent: "할 일을 완료해 보세요!"
                            ) {
                                self.todoState.updateOrderMain()
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
                        } offsetChanged: {
                            self.changeOffset($0)
                        }
                    } else {
                        if let tag = viewModel.selectedTag {
                            if tag.id == DefaultTag.important.rawValue {
                                ListView(checkListViewModel: self.viewModel) {
                                    ListSectionView(
                                        checkListViewModel: self.viewModel,
                                        todoAddViewModel: self.addViewModel,
                                        todoList: self.$todoState.todoListByFlag
                                    ) {
                                        self.todoState.updateOrderFlag()
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
                                    self.changeOffset($0)
                                }
                            } else if tag.id == DefaultTag.unclassified.rawValue {
                                ListView(checkListViewModel: self.viewModel) {
                                    ListSectionView(
                                        checkListViewModel: self.viewModel,
                                        todoAddViewModel: self.addViewModel,
                                        todoList: self.$todoState.todoListWithoutTag
                                    ) {
                                        self.todoState.updateOrderWithoutTag()
                                    } header: {
                                        TagView(
                                            tag: tag,
                                            isSelected: true,
                                            disabled: self.todoState.todoListWithoutTag.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else if tag.id == DefaultTag.completed.rawValue {
                                ListView(checkListViewModel: self.viewModel) {
                                    ListSectionView(
                                        checkListViewModel: self.viewModel,
                                        todoAddViewModel: self.addViewModel,
                                        todoList: self.$todoState.todoListByCompleted,
                                        emptyTextContent: "할 일을 완료해 보세요!"
                                    ) {
                                        self.todoState.updateOrderWithoutTag()
                                    } header: {
                                        TagView(
                                            tag: tag,
                                            isSelected: true,
                                            disabled: self.todoState.todoListByCompleted.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }
                                } offsetChanged: {
                                    self.changeOffset($0)
                                }
                            } else {
                                // Tag 클릭시
                                ListView(checkListViewModel: self.viewModel) {
                                    ListSectionView(
                                        checkListViewModel: self.viewModel,
                                        todoAddViewModel: self.addViewModel,
                                        todoList: self.$todoState.todoListByFlag,
                                        emptyTextContent: "중요한 할 일이 있나요?"
                                    ) {
                                        self.todoState.updateOrderByTag(tagId: tag.id)
                                    } header: {
                                        TagView(
                                            tag: Tag(
                                                id: DefaultTag.important.rawValue,
                                                content: DefaultTag.important.rawValue
                                            ),
                                            isSelected: true,
                                            disabled: self.todoState.todoListByFlag.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }

                                    Divider()

                                    ListSectionView(
                                        checkListViewModel: self.viewModel,
                                        todoAddViewModel: self.addViewModel,
                                        todoList: self.$todoState.todoListByTag
                                    ) {
                                        self.todoState.updateOrderByTag(tagId: tag.id)
                                    } header: {
                                        TagView(
                                            tag: tag,
                                            isSelected: true,
                                            disabled: self.todoState.todoListByTag.isEmpty
                                        )
                                        .padding(.leading, 10)
                                    }

                                    Divider()

                                    ListSectionView(
                                        checkListViewModel: self.viewModel,
                                        todoAddViewModel: self.addViewModel,
                                        todoList: self.$todoState.todoListByCompleted,
                                        emptyTextContent: "할 일을 완료해 보세요!"
                                    ) {
                                        self.todoState.updateOrderByTag(tagId: tag.id)
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
            .background(Color(0xfdfdfd))

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
                    checkListViewModel: self.viewModel,
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
                        .background(Color(0xf1f1f5))
                        .cornerRadius(8)
                        .padding(.trailing, 18)
                        .padding(.bottom, 4)
                        .focused(self.$isTextFieldFocused)
                        .onSubmit {
                            self.addViewModel.addSimpleTodo()
                        }

                    Button {
                        withAnimation {
                            self.isModalVisible = true
                            self.addViewModel.mode = .add
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
        .onAppear {
            self.isModalVisible = false
            isTagManageModalVisible.wrappedValue = false
            self.viewModel.selectedTag = nil
            self.viewModel.fetchTodoList()
            self.viewModel.fetchTags()
            UIApplication.shared.addTapGestureRecognizer()
        }
        .onChange(of: self.isTextFieldFocused, perform: { value in
            if self.isModalVisible {
                return
            }
            if !self.isTextFieldFocused {
                self.addViewModel.content = ""
            }

            withAnimation {
                Global.shared.isTabViewActive = !value
            }
        })
        .contentShape(Rectangle())
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
