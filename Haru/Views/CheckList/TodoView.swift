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
        formatter.dateFormat = "yyyy-MM-dd, hh:mm"
        return formatter
    }()

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

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.content)
                    .font(.body)

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
                            todo.repeat != nil ||
                            todo.repeatOption != nil ||
                            !todo.memo.isEmpty)
                    {
                        Text("∙")
                    }

                    if todo.alarms.count > 0 {
                        Image(systemName: "bell")
                    }

                    if todo.repeat != nil || todo.repeatOption != nil {
                        Image(systemName: "repeat")
                    }

                    if !todo.memo.isEmpty {
                        Image(systemName: "note")
                    }
                }
                .font(.caption2)
                .foregroundColor(Color(0x000000, opacity: 0.5))
            }
            .padding(.leading, 10)

            Spacer()

            Button {
                checkListViewModel.updateFlag(todo) { _ in }
            } label: {
                if todo.flag {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "star")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
