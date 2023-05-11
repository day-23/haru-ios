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
    var itemBackgroundColor: Color = .white
    var emptyTextContent: String = "모든 할 일을 마쳤습니다!"
    let orderAction: () -> Void
    @ViewBuilder let header: () -> Content

    var body: some View {
        Section {
            if todoList.isEmpty {
                EmptySectionView(
                    content: emptyTextContent
                )
                .padding(.leading, 40)
            } else {
                ForEach(todoList) { todo in
                    NavigationLink {
                        TodoAddView(viewModel: todoAddViewModel)
                            .onAppear {
                                todoAddViewModel.mode = .edit
                                todoAddViewModel.todo = todo
                                todoAddViewModel.applyTodoData(todo: todo)
                            }
                    } label: {
                        TodoView(
                            checkListViewModel: checkListViewModel,
                            todo: todo,
                            backgroundColor: itemBackgroundColor
                        )
                        .foregroundColor(.black)
                    }

                    if !todo.folded {
                        ForEach(todo.subTodos) { subTodo in
                            SubTodoView(
                                checkListViewModel: checkListViewModel,
                                todo: todo,
                                subTodo: subTodo,
                                backgroundColor: itemBackgroundColor
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
                    .padding(.top, 1)
                Spacer()
            }
            .background(itemBackgroundColor)
        }
    }
}
