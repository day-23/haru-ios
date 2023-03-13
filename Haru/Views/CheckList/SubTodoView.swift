//
//  SubTodoView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/13.
//

import SwiftUI

struct SubTodoView: View {
    var checkListViewModel: CheckListViewModel
    var subTodo: SubTodo

    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .overlay {
                    Circle()
                        .stroke()
                        .foregroundColor(Color(0x000000, opacity: 0.3))
                }

            Text(subTodo.content)
                .padding(.leading, 10)
        }
    }
}
