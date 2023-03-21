//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI
import UniformTypeIdentifiers

struct CheckListView: View {
    struct EmptyText: View {
        var body: some View {
            Text("모든 할 일을 마쳤습니다!")
                .font(.footnote)
                .foregroundColor(Color(0x000000, opacity: 0.5))
                .padding(.leading)
        }
    }

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
                    // 태그 리스트
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // 중요 태그
                            Image(systemName: "star.fill")
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Constants.gradientEnd,
                                        Constants.gradientStart,
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.selectedTag = Tag(
                                            id: "중요",
                                            content: "중요"
                                        )
                                    }
                                    initialOffset = nil
                                }

                            // 미분류 태그
                            TagView(Tag(id: "미분류", content: "미분류"))
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.selectedTag = Tag(
                                            id: "미분류",
                                            content: "미분류"
                                        )
                                    }
                                    initialOffset = nil
                                }

                            // 완료 태그
                            TagView(Tag(id: "완료", content: "완료"))

                            ForEach(viewModel.tagList) { tag in
                                TagView(tag)
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectedTag = tag
                                        }
                                        initialOffset = nil
                                    }
                            }
                        }
                        .padding()
                    }

                    // 오늘 나의 하루 클릭시
                    HStack {
                        Text("오늘 나의 하루")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .scaleEffect(1.25)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 15)
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

                    // 체크 리스트
                    if !viewModel.isEmpty {
                        List {
                            if viewModel.selectedTag == nil {
                                Section {
                                    if !viewModel.todoListByFlag.isEmpty {
                                        ForEach(viewModel.todoListByFlag) { todo in
                                            TodoView(
                                                checkListViewModel: viewModel,
                                                todo: todo
                                            ).overlay {
                                                NavigationLink {
                                                    TodoAddView(viewModel: addViewModel)
                                                        .onAppear {
                                                            withAnimation {
                                                                addViewModel.applyTodoData(todo: todo)
                                                                addViewModel.mode = .edit
                                                                addViewModel.todoId = todo.id
                                                            }
                                                        }
                                                } label: {
                                                    EmptyView()
                                                }
                                                .opacity(0)
                                            }

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(
                                                    checkListViewModel: viewModel,
                                                    todo: todo,
                                                    subTodo: subTodo
                                                )
                                            }
                                            .moveDisabled(true)
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                        .onMove(perform: { indexSet, index in
                                            viewModel.todoListByFlag.move(fromOffsets: indexSet, toOffset: index)
                                            viewModel.updateOrderMain()
                                        })
                                        .listRowBackground(Color.white)
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(
                                                        colors: [Constants.gradientEnd,
                                                                 Constants.gradientStart]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                    .listRowInsets(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 1,
                                        trailing: 0
                                    ))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)

                                Divider()
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())

                                Section {
                                    if !viewModel.todoListWithAnyTag.isEmpty {
                                        ForEach(viewModel.todoListWithAnyTag) { todo in
                                            TodoView(
                                                checkListViewModel: viewModel,
                                                todo: todo
                                            ).overlay {
                                                NavigationLink {
                                                    TodoAddView(viewModel: addViewModel)
                                                        .onAppear {
                                                            withAnimation {
                                                                addViewModel.applyTodoData(todo: todo)
                                                                addViewModel.mode = .edit
                                                                addViewModel.todoId = todo.id
                                                            }
                                                        }
                                                } label: {
                                                    EmptyView()
                                                }
                                                .opacity(0)
                                            }

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(
                                                    checkListViewModel: viewModel,
                                                    todo: todo,
                                                    subTodo: subTodo
                                                )
                                            }
                                            .moveDisabled(true)
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                        .onMove(perform: { indexSet, index in
                                            viewModel.todoListWithAnyTag.move(fromOffsets: indexSet, toOffset: index)
                                            viewModel.updateOrderMain()
                                        })
                                        .listRowBackground(Color.white)
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        TagView(Tag(id: "분류됨", content: "분류됨"))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .listRowInsets(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 1,
                                        trailing: 0
                                    ))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)

                                Divider()
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())

                                Section {
                                    if !viewModel.todoListWithoutTag.isEmpty {
                                        ForEach(viewModel.todoListWithoutTag) { todo in
                                            TodoView(
                                                checkListViewModel: viewModel,
                                                todo: todo
                                            ).overlay {
                                                NavigationLink {
                                                    TodoAddView(viewModel: addViewModel)
                                                        .onAppear {
                                                            withAnimation {
                                                                addViewModel.applyTodoData(todo: todo)
                                                                addViewModel.mode = .edit
                                                                addViewModel.todoId = todo.id
                                                            }
                                                        }
                                                } label: {
                                                    EmptyView()
                                                }
                                                .opacity(0)
                                            }

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(
                                                    checkListViewModel: viewModel,
                                                    todo: todo,
                                                    subTodo: subTodo
                                                )
                                            }
                                            .moveDisabled(true)
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                        .onMove(perform: { indexSet, index in
                                            viewModel.todoListWithoutTag.move(fromOffsets: indexSet, toOffset: index)
                                            viewModel.updateOrderMain()
                                        })
                                        .listRowBackground(Color.white)
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        TagView(Tag(id: "미분류", content: "미분류"))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .listRowInsets(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 1,
                                        trailing: 0
                                    ))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)

                                Divider()
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())

                                Section {
                                    if !viewModel.todoListByCompleted.isEmpty {
                                        ForEach(viewModel.todoListByCompleted) { todo in
                                            TodoView(
                                                checkListViewModel: viewModel,
                                                todo: todo
                                            ).overlay {
                                                NavigationLink {
                                                    TodoAddView(viewModel: addViewModel)
                                                        .onAppear {
                                                            withAnimation {
                                                                addViewModel.applyTodoData(todo: todo)
                                                                addViewModel.mode = .edit
                                                                addViewModel.todoId = todo.id
                                                            }
                                                        }
                                                } label: {
                                                    EmptyView()
                                                }
                                                .opacity(0)
                                            }

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(
                                                    checkListViewModel: viewModel,
                                                    todo: todo,
                                                    subTodo: subTodo
                                                )
                                            }
                                            .moveDisabled(true)
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                        .onMove(perform: { indexSet, index in
                                            viewModel.todoListByCompleted.move(fromOffsets: indexSet, toOffset: index)
                                            viewModel.updateOrderMain()
                                        })
                                        .listRowBackground(Color.white)
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        TagView(Tag(id: "완료", content: "완료"))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .listRowInsets(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 1,
                                        trailing: 0
                                    ))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)
                            } else {
                                if let tag = viewModel.selectedTag {
                                    if tag.id == "하루" {
                                        Section {
                                            if !viewModel.todoListByFlagWithToday.isEmpty {
                                                ForEach(viewModel.todoListByFlagWithToday) { todo in
                                                    TodoView(
                                                        checkListViewModel: viewModel,
                                                        todo: todo
                                                    ).overlay {
                                                        NavigationLink {
                                                            TodoAddView(viewModel: addViewModel)
                                                                .onAppear {
                                                                    withAnimation {
                                                                        addViewModel.applyTodoData(todo: todo)
                                                                        addViewModel.mode = .edit
                                                                        addViewModel.todoId = todo.id
                                                                    }
                                                                }
                                                        } label: {
                                                            EmptyView()
                                                        }
                                                        .opacity(0)
                                                    }

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(
                                                            checkListViewModel: viewModel,
                                                            todo: todo,
                                                            subTodo: subTodo
                                                        )
                                                    }
                                                    .moveDisabled(true)
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                                .onMove(perform: { indexSet, index in
                                                    viewModel.todoListByFlagWithToday.move(fromOffsets: indexSet, toOffset: index)
                                                    viewModel.updateOrderHaru()
                                                })
                                                .listRowBackground(Color.white)
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            gradient: Gradient(
                                                                colors: [Constants.gradientEnd,
                                                                         Constants.gradientStart]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 1,
                                                trailing: 0
                                            ))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)

                                        Section {
                                            if !viewModel.todoListByTodayTodo.isEmpty {
                                                ForEach(viewModel.todoListByTodayTodo) { todo in
                                                    TodoView(
                                                        checkListViewModel: viewModel,
                                                        todo: todo
                                                    ).overlay {
                                                        NavigationLink {
                                                            TodoAddView(viewModel: addViewModel)
                                                                .onAppear {
                                                                    withAnimation {
                                                                        addViewModel.applyTodoData(todo: todo)
                                                                        addViewModel.mode = .edit
                                                                        addViewModel.todoId = todo.id
                                                                    }
                                                                }
                                                        } label: {
                                                            EmptyView()
                                                        }
                                                        .opacity(0)
                                                    }

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(
                                                            checkListViewModel: viewModel,
                                                            todo: todo,
                                                            subTodo: subTodo
                                                        )
                                                    }
                                                    .moveDisabled(true)
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                                .onMove(perform: { indexSet, index in
                                                    viewModel.todoListByTodayTodo.move(fromOffsets: indexSet, toOffset: index)
                                                    viewModel.updateOrderHaru()
                                                })
                                                .listRowBackground(Color.white)
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                TagView(Tag(
                                                    id: "오늘 할 일",
                                                    content: "오늘 할 일"
                                                ))
                                                .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 1,
                                                trailing: 0
                                            ))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)

                                        Section {
                                            if !viewModel.todoListByUntilToday.isEmpty {
                                                ForEach(viewModel.todoListByUntilToday) { todo in
                                                    TodoView(
                                                        checkListViewModel: viewModel,
                                                        todo: todo
                                                    ).overlay {
                                                        NavigationLink {
                                                            TodoAddView(viewModel: addViewModel)
                                                                .onAppear {
                                                                    withAnimation {
                                                                        addViewModel.applyTodoData(todo: todo)
                                                                        addViewModel.mode = .edit
                                                                        addViewModel.todoId = todo.id
                                                                    }
                                                                }
                                                        } label: {
                                                            EmptyView()
                                                        }
                                                        .opacity(0)
                                                    }

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(
                                                            checkListViewModel: viewModel,
                                                            todo: todo,
                                                            subTodo: subTodo
                                                        )
                                                    }
                                                    .moveDisabled(true)
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                                .onMove(perform: { indexSet, index in
                                                    viewModel.todoListByUntilToday.move(fromOffsets: indexSet, toOffset: index)
                                                    viewModel.updateOrderHaru()
                                                })
                                                .listRowBackground(Color.white)
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                TagView(Tag(
                                                    id: "오늘까지",
                                                    content: "오늘까지"
                                                ))
                                                .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 1,
                                                trailing: 0
                                            ))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)
                                    } else if tag.id == "중요" {
                                        Section {
                                            if !viewModel.todoListByFlag.isEmpty {
                                                ForEach(viewModel.todoListByFlag) { todo in
                                                    TodoView(
                                                        checkListViewModel: viewModel,
                                                        todo: todo
                                                    ).overlay {
                                                        NavigationLink {
                                                            TodoAddView(viewModel: addViewModel)
                                                                .onAppear {
                                                                    withAnimation {
                                                                        addViewModel.applyTodoData(todo: todo)
                                                                        addViewModel.mode = .edit
                                                                        addViewModel.todoId = todo.id
                                                                    }
                                                                }
                                                        } label: {
                                                            EmptyView()
                                                        }
                                                        .opacity(0)
                                                    }

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(
                                                            checkListViewModel: viewModel,
                                                            todo: todo,
                                                            subTodo: subTodo
                                                        )
                                                    }
                                                    .moveDisabled(true)
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                                .onMove(perform: { indexSet, index in
                                                    viewModel.todoListByFlag.move(fromOffsets: indexSet, toOffset: index)
                                                    viewModel.updateOrderFlag()
                                                })
                                                .listRowBackground(Color.white)
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            gradient: Gradient(
                                                                colors: [Constants.gradientEnd,
                                                                         Constants.gradientStart]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 1,
                                                trailing: 0
                                            ))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)
                                    } else if tag.id == "미분류" {
                                        Section {
                                            if !viewModel.todoListWithoutTag.isEmpty {
                                                ForEach(viewModel.todoListWithoutTag) { todo in
                                                    TodoView(
                                                        checkListViewModel: viewModel,
                                                        todo: todo
                                                    ).overlay {
                                                        NavigationLink {
                                                            TodoAddView(viewModel: addViewModel)
                                                                .onAppear {
                                                                    withAnimation {
                                                                        addViewModel.applyTodoData(todo: todo)
                                                                        addViewModel.mode = .edit
                                                                        addViewModel.todoId = todo.id
                                                                    }
                                                                }
                                                        } label: {
                                                            EmptyView()
                                                        }
                                                        .opacity(0)
                                                    }

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(
                                                            checkListViewModel: viewModel,
                                                            todo: todo,
                                                            subTodo: subTodo
                                                        )
                                                    }
                                                    .moveDisabled(true)
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                                .onMove(perform: { indexSet, index in
                                                    viewModel.todoListWithoutTag.move(fromOffsets: indexSet, toOffset: index)
                                                    viewModel.updateOrderWithoutTag()
                                                })
                                                .listRowBackground(Color.white)
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                TagView(tag)
                                                    .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 1,
                                                trailing: 0
                                            ))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)
                                    } else {
                                        Section {
                                            if !viewModel.todoListByTag.isEmpty {
                                                ForEach(viewModel.todoListByTag) { todo in
                                                    TodoView(
                                                        checkListViewModel: viewModel,
                                                        todo: todo
                                                    ).overlay {
                                                        NavigationLink {
                                                            TodoAddView(viewModel: addViewModel)
                                                                .onAppear {
                                                                    withAnimation {
                                                                        addViewModel.applyTodoData(todo: todo)
                                                                        addViewModel.mode = .edit
                                                                        addViewModel.todoId = todo.id
                                                                    }
                                                                }
                                                        } label: {
                                                            EmptyView()
                                                        }
                                                        .opacity(0)
                                                    }

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(
                                                            checkListViewModel: viewModel,
                                                            todo: todo,
                                                            subTodo: subTodo
                                                        )
                                                    }
                                                    .moveDisabled(true)
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                                .onMove(perform: { indexSet, index in
                                                    viewModel.todoListByTag.move(fromOffsets: indexSet, toOffset: index)
                                                    viewModel.updateOrderByTag(tagId: tag.id)
                                                })
                                                .listRowBackground(Color.white)
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                TagView(tag)
                                                    .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 1,
                                                trailing: 0
                                            ))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)
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
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding()
                                .background(LinearGradient(
                                    gradient: Gradient(
                                        colors: [Color(0xD2D7FF),
                                                 Color(0xAAD7FF)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .clipShape(Circle())
                                .frame(alignment: .center)
                        }
                        .zIndex(5)
                        .padding()
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
