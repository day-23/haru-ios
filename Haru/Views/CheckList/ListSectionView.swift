//
//  ListSectionView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/14.
//

import SwiftUI

struct ListSectionView<Title>: View where Title: View {
    var viewModel: CheckListViewModel
    var todoList: [Todo]
    var title: () -> Title

    var body: some View {
        VStack {
            title()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

            VStack {
                ForEach(todoList) { todo in
                    TodoView(
                        checkListViewModel: viewModel,
                        todo: todo
                    )
                    .contextMenu {
                        Button(action: {
                            viewModel.deleteTodo(todo) { _ in
                                viewModel.fetchTodoList { _ in }
                            }
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }

                    ForEach(todo.subTodos) { subTodo in
                        SubTodoView(checkListViewModel: viewModel, subTodo: subTodo)
                            .contextMenu {
                                Button(action: {
                                    viewModel.deleteSubTodo(todo, subTodo) { _ in
                                        viewModel.fetchTodoList { _ in }
                                    }
                                }, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }
                    }
                    .padding(.leading, UIScreen.main.bounds.width * 0.05)

                    Rectangle()
                        .frame(height: 5)
                        .background(.clear)
                        .foregroundColor(.clear)
                }
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity)
    }
}
