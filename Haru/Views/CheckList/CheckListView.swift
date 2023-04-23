//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

//  TODO: Todo가 추가되면, Todo가 추가된 화면을 쫓아가도록 수정
//  TODO: Date Picker Component 추가
//  TODO: 오늘 나의 하루로 체크되어 있으면, 완료 체크 애니메이션이 안되는 문제 해결 필요
//  TODO: 반복일정 날짜 체크시 오류 있음, 수정 필요
//  TODO: 수정시에 아무런 변경사항이 없다면 체크 버튼을 비활성화하는 방법을 선택

import SwiftUI

struct CheckListView: View {
    @StateObject var viewModel: CheckListViewModel
    @StateObject var addViewModel: TodoAddViewModel
    @State private var isModalVisible: Bool = false
    @State private var prevOffset: CGFloat?
    @State private var offset: CGFloat?
    @State private var viewIsShown: Bool = true
    @State private var bottomOffset: CGFloat?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                //  태그 리스트
                TagListView(viewModel: viewModel) { tag in
                    withAnimation {
                        viewModel.selectedTag = tag
                        prevOffset = nil
                        bottomOffset = nil
                    }
                }
                .padding(.bottom, 10)

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
                                ListView {
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
                                ListView {
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
                                ListView {
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
                                ListView {
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
            } else {
                if viewIsShown {
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
        }
        .onAppear {
            isModalVisible = false
            viewModel.selectedTag = nil
            viewModel.fetchTodoList()
            viewModel.fetchTags()
        }
    }

    func changeOffset(_ value: CGPoint?) {
        if self.prevOffset == nil {
            self.viewIsShown = true
            self.prevOffset = value?.y
            self.bottomOffset = value?.y
            return
        }
        self.offset = value?.y

        guard let prevOffset,
              let offset,
              let bottomOffset
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

        self.bottomOffset = min(bottomOffset, offset)
    }
}
