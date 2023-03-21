//
//  TodoItem.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct TodoView: View {
    var checkListViewModel: CheckListViewModel
    var todo: Todo

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    let formatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, HH:mm"
        return formatter
    }()

    var body: some View {
        // Todo Item
        HStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .overlay {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color(0x000000, opacity: 0.5))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.content)
                    .font(.body)

                if todo.tags.count > 0 ||
                    todo.endDate != nil ||
                    todo.endDateTime != nil ||
                    todo.alarms.count > 0 ||
                    todo.repeatValue != nil ||
                    todo.repeatOption != nil ||
                    !todo.memo.isEmpty
                {
                    HStack {
                        ForEach(todo.tags) { tag in
                            Text(tag.content)
                        }

                        if let todoDate = todo.endDate {
                            if let todoDateTime = todo.endDateTime {
                                Text(formatterWithTime.string(from: todoDateTime))
                            } else {
                                Text(formatter.string(from: todoDate))
                            }
                        }

                        if (todo.tags.count > 0 ||
                            todo.endDate != nil ||
                            todo.endDateTime != nil) &&
                            (todo.alarms.count > 0 ||
                                todo.repeatValue != nil ||
                                todo.repeatOption != nil ||
                                !todo.memo.isEmpty)
                        {
                            Text("∙")
                        }

                        if todo.alarms.count > 0 {
                            Image(systemName: "bell")
                        }

                        if todo.repeatValue != nil || todo.repeatOption != nil {
                            Image(systemName: "repeat")
                        }

                        if !todo.memo.isEmpty {
                            Image(systemName: "note")
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(Color(0x000000, opacity: 0.5))
                }
            }
            .padding(.leading, 10)

            Spacer()

            ZStack {
                Image(systemName: todo.flag ? "star.fill" : "star")
                    .foregroundStyle(todo.flag ? LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color(0x000000, opacity: 0.4)]), startPoint: .top, endPoint: .bottom))
                    .onTapGesture {
                        checkListViewModel.updateFlag(todo: todo) { _ in }
                    }
            }
        }
        .background(.white)
        .contextMenu {
            Button(action: {
                checkListViewModel.deleteTodo(todoId: todo.id) { _ in
                    checkListViewModel.fetchTodoList()
                }
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
}
