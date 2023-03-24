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
    var backgroundColor: Color = .white

    var body: some View {
        HStack(spacing: 0) {
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
                .strikethrough(subTodo.completed)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(!subTodo.completed ? Color(0x191919) : Color(0xacacac))

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .padding(.leading, 54)
        .padding(.trailing, 20)
        .background(backgroundColor)
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
