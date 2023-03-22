//
//  ListSectionView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct ListSectionView<Content>: View where Content: View {
    var checkListViewModel: CheckListViewModel
    var todoAddViewModel: TodoAddViewModel
    @Binding var todoList: [Todo]
    let orderAction: () -> Void
    @ViewBuilder let header: () -> Content

    init(checkListViewModel: CheckListViewModel,
         todoAddViewModel: TodoAddViewModel,
         todoList: Binding<[Todo]>,
         orderAction: @escaping () -> Void,
         @ViewBuilder header: @escaping () -> Content)
    {
        self.checkListViewModel = checkListViewModel
        self.todoAddViewModel = todoAddViewModel
        self._todoList = todoList
        self.orderAction = orderAction
        self.header = header
    }

    var body: some View {
        Section {
            if todoList.isEmpty {
                EmptySectionView()
            } else {
                ForEach(todoList) { todo in
                    TodoView(
                        checkListViewModel: checkListViewModel,
                        todo: todo
                    ).overlay {
                        NavigationLink {
                            TodoAddView(viewModel: todoAddViewModel)
                                .onAppear {
                                    withAnimation {
                                        todoAddViewModel.applyTodoData(todo: todo)
                                        todoAddViewModel.mode = .edit
                                        todoAddViewModel.todoId = todo.id
                                    }
                                }
                        } label: {
                            EmptyView()
                        }
                        .opacity(0)
                    }

                    if todo.isShowingSubTodo {
                        ForEach(todo.subTodos) { subTodo in
                            SubTodoView(
                                checkListViewModel: checkListViewModel,
                                todo: todo,
                                subTodo: subTodo
                            )
                        }
                        .moveDisabled(true)
                    }
                }
                .onMove(perform: { indexSet, index in
                    todoList.move(fromOffsets: indexSet, toOffset: index)
                    orderAction()
                })
                .listRowBackground(Color.white)
            }
        } header: {
            HStack {
                header()
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
        .listRowInsets(EdgeInsets())
    }
}
