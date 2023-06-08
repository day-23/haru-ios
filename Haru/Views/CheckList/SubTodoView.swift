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
        HStack(alignment: .top, spacing: 0) {
            CompleteButton(isClicked: subTodo.completed)
                .onTapGesture {
                    checkListViewModel.completeSubTodo(
                        subTodoId: subTodo.id,
                        completed: !subTodo.completed
                    )
                }
                .padding(.trailing, 8)

            Text(subTodo.content)
                .strikethrough(subTodo.completed)
                .font(.pretendard(size: 16, weight: .bold))
                .foregroundColor(!subTodo.completed ? Color(0x191919) : Color(0xacacac))
                .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, 70)
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
