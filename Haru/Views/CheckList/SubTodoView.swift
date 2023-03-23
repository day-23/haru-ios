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
                .padding(.trailing, 14)

            Text(subTodo.content)
                .font(.system(size: 14, weight: .bold))
                .strikethrough(subTodo.completed)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .padding(.leading, 54)
        .padding(.trailing, 20)
        .background(Color(0xffffff, opacity: 0.01))
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
