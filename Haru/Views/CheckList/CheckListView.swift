//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct CheckListView: View {
    @StateObject var viewModel: CheckListViewModel
    @State private var isModalVisible: Bool = false
    @State private var isScrolled: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.tagList) { tag in
                                TagView(tag)
                            }
                        }
                        .padding()
                    }

                    if viewModel.todoList.count > 0 {
                        List {
                            ForEach(viewModel.todoList) { todo in
                                TodoView(
                                    checkListViewModel: viewModel,
                                    todo: todo
                                )
                                .frame(height: geometry.size.height * 0.06)
                                .contextMenu {
                                    Button(action: {
                                        if let index = viewModel.todoList.firstIndex(where: { $0.id == todo.id
                                        }) {
                                            viewModel.deleteTodo(viewModel.todoList[index].id) { _ in
                                                viewModel.todoList.remove(at: index)
                                                viewModel.fetchTodoList { _ in }
                                            }
                                        }
                                    }, label: {
                                        Label("Delete", systemImage: "trash")
                                    })
                                }

                                ForEach(todo.subTodos) { subTodo in
                                    SubTodoView(checkListViewModel: viewModel, subTodo: subTodo)
                                }
                                .padding(.leading, geometry.size.width * 0.05)
                            }
                        }
                        .simultaneousGesture(DragGesture().onChanged { value in
                            if value.startLocation.y - value.location.y > 0 {
                                withAnimation {
                                    isScrolled = true
                                }
                            } else {
                                withAnimation {
                                    isScrolled = false
                                }
                            }
                        })
                        .listStyle(.inset)
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
                    if !isScrolled {
                        Button {
                            withAnimation {
                                isModalVisible = true
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .scaleEffect(2)
                                .padding(.all, 30)
                        }
                        .zIndex(5)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchTodoList { _ in }
            viewModel.fetchTags { _ in }
        }
    }
}
