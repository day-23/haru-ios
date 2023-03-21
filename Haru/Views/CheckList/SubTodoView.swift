//
//  SubTodoView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/13.
//

import SwiftUI

struct SubTodoView: View {
    var checkListViewModel: CheckListViewModel
    var todo: Todo
    var subTodo: SubTodo

    var body: some View {
        HStack {
            CompleteButton(isClicked: subTodo.completed)
                .onTapGesture {
                    checkListViewModel.completeSubTodo(subTodoId: subTodo.id,
                                                       completed: !subTodo.completed) { result in
                        switch result {
                        case .success:
                            checkListViewModel.fetchTodoList()
                        case .failure(let failure):
                            print("[Debug] \(failure) (\(#fileID), \(#function))")
                        }
                    }
                }

            Text(subTodo.content)
                .strikethrough(subTodo.completed)

            Spacer()
        }
        .background(.white)
        .contextMenu {
            Button(action: {
                checkListViewModel.deleteSubTodo(todoId: todo.id, subTodoId: subTodo.id) { _ in
                    checkListViewModel.fetchTodoList()
                }
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
}
