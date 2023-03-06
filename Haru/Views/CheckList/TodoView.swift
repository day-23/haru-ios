//
//  TodoItem.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct TodoView: View {
    var todo: Todo

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
                .padding(.trailing, 5)

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.content)
                    .font(.body)
                Text(todo.memo)
                    .font(.caption2)
                    .foregroundColor(Color(0x000000, opacity: 0.5))
            }

            Spacer()

            Image(systemName: "star")
                .foregroundColor(Color(0x000000, opacity: 0.4))
        }
    }
}
