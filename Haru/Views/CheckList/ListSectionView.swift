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
                        TodoView(checkListViewModel: checkListViewModel,
                                 todo: todo)
                            .foregroundColor(.black)
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
                    //  ScrollView로 변경함으로써 알고리즘 변경 필요
                    todoList.move(fromOffsets: indexSet, toOffset: index)
                    orderAction()
                })
            }
        } header: {
            HStack {
                header()
                Spacer()
            }
            .background(Color(0xffffff, opacity: 0.01))
        }
    }
}
