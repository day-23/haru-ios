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
            Circle()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .overlay {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color(0x000000, opacity: 0.5))
                }

            Text(subTodo.content)
                .padding(.leading, 10)

            Spacer()
        }
        .background(.white)
        .contextMenu {
            Button(action: {
                checkListViewModel.deleteSubTodo(todo: todo, subTodo: subTodo) { _ in
                    checkListViewModel.fetchTodoList()
                }
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
}
