//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

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
    @State private var isModalVisible: Bool = false
    @State var initialOffset: CGFloat?
    @State var offset: CGFloat?
    @State var viewIsShown: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    // 태그 리스트
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // 중요 태그
                            Image(systemName: "star.fill")
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .onTapGesture {
                                    viewModel.selectedTag = Tag(id: "중요", content: "중요")
                                }

                            // 미분류 태그
                            TagView(Tag(id: "미분류", content: "미분류"))
                                .onTapGesture {
                                    viewModel.selectedTag = Tag(id: "미분류", content: "미분류")
                                }

                            // 완료 태그
                            TagView(Tag(id: "완료", content: "완료"))

                            ForEach(viewModel.tagList) { tag in
                                TagView(tag)
                                    .onTapGesture {
                                        viewModel.selectedTag = tag
                                    }
                            }
                        }
                        .padding()
                    }

                    // 오늘 나의 하루 클릭시
                    HStack {
                        Text("오늘 나의 하루")
                            .font(.system(size: 20, weight: .heavy))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .scaleEffect(1.25)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 15)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .leading, endPoint: .trailing)
                    )
                    .onTapGesture {
                        viewModel.selectedTag = Tag(id: "하루", content: "하루")
                    }

                    // 체크 리스트
                    if viewModel.todoList.count > 0 {
                        List {
                            if viewModel.selectedTag == nil {
                                Section {
                                    if let todoList = viewModel.filterTodoByFlag(), !todoList.isEmpty {
                                        ForEach(todoList) { todo in
                                            TodoView(checkListViewModel: viewModel, todo: todo)

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(checkListViewModel: viewModel, todo: todo, subTodo: subTodo)
                                            }
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)

                                Section {
                                    if let todoList = viewModel.filterTodoByHasAnyTag(), !todoList.isEmpty {
                                        ForEach(todoList) { todo in
                                            TodoView(checkListViewModel: viewModel, todo: todo)

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(checkListViewModel: viewModel, todo: todo, subTodo: subTodo)
                                            }
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        TagView(
                                            Tag(id: "분류됨", content: "분류됨")
                                        )
                                        .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)

                                Section {
                                    if let todoList = viewModel.filterTodoByWithoutTag(), !todoList.isEmpty {
                                        ForEach(todoList) { todo in
                                            TodoView(checkListViewModel: viewModel, todo: todo)

                                            ForEach(todo.subTodos) { subTodo in
                                                SubTodoView(checkListViewModel: viewModel, todo: todo, subTodo: subTodo)
                                            }
                                            .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                        }
                                    } else {
                                        EmptyText()
                                    }
                                } header: {
                                    HStack {
                                        TagView(
                                            Tag(id: "미분류", content: "미분류")
                                        )
                                        .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                    .background(.white)
                                }
                                .listRowSeparator(.hidden)
                            } else {
                                if let tag = viewModel.selectedTag {
                                    if tag.content == "하루" {
                                        Section {
                                            if let todoList = viewModel.filterTodoByTodayTodo(), !todoList.isEmpty {
                                                ForEach(todoList) { todo in
                                                    TodoView(checkListViewModel: viewModel, todo: todo)

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(checkListViewModel: viewModel, todo: todo, subTodo: subTodo)
                                                    }
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                TagView(Tag(id: "오늘 할 일", content: "오늘 할 일"))
                                                    .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)

                                        Section {
                                            if let todoList = viewModel.filterTodoByTodayEndDate(), !todoList.isEmpty {
                                                ForEach(todoList) { todo in
                                                    TodoView(checkListViewModel: viewModel, todo: todo)

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(checkListViewModel: viewModel, todo: todo, subTodo: subTodo)
                                                    }
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                TagView(Tag(id: "오늘까지", content: "오늘까지"))
                                                    .padding(.leading, 20)
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)
                                    } else {
                                        Section {
                                            if let todoList = viewModel.filterTodoByTag(), !todoList.isEmpty {
                                                ForEach(todoList) { todo in
                                                    TodoView(checkListViewModel: viewModel, todo: todo)

                                                    ForEach(todo.subTodos) { subTodo in
                                                        SubTodoView(checkListViewModel: viewModel, todo: todo, subTodo: subTodo)
                                                    }
                                                    .padding(.leading, UIScreen.main.bounds.width * 0.05)
                                                }
                                            } else {
                                                EmptyText()
                                            }
                                        } header: {
                                            HStack {
                                                if tag.id != "중요" {
                                                    TagView(tag)
                                                        .padding(.leading, 20)
                                                    Spacer()
                                                } else {
                                                    Image(systemName: "star.fill")
                                                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                        .padding(.leading, 20)
                                                    Spacer()
                                                }
                                            }
                                            .padding(.vertical, 5)
                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                            .background(.white)
                                        }
                                        .listRowSeparator(.hidden)
                                    }
                                }
                            }

                            GeometryReader { geometry in
                                Color.clear.preference(key: OffsetKey.self, value: geometry.frame(in: .global).minY).frame(height: 0)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.inset)
                        .onPreferenceChange(OffsetKey.self) {
                            if self.initialOffset == nil || self.initialOffset == 0 {
                                self.initialOffset = $0
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
                            viewModel: TodoAddViewModel(checkListViewModel: viewModel),
                            isActive: $isModalVisible
                        )
                    }
                    .transition(.modal)
                    .zIndex(2)
                } else {
                    if viewIsShown {
                        Button {
                            withAnimation {
                                isModalVisible = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Constants.gradientStart, Constants.gradientEnd]), startPoint: .bottomTrailing, endPoint: .topLeading))
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
            viewModel.selectedTag = nil
            viewModel.fetchTodoList { _ in }
            viewModel.fetchTags { _ in }
        }
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}
