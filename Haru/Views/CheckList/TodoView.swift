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
        formatter.dateFormat = "yyyy-MM-dd, hh:mm:ss"
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
                .padding(.trailing, 5)

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.content)
                    .font(.body)
                    .padding(.all, todo.memo.isEmpty ? 10 : 0)
                HStack {
                    Group {
                        if !todo.memo.isEmpty {
                            Text("\(todo.memo)")
                        }

                        if let endDate = todo.endDate {
                            if let endDateTime = todo.endDateTime {
                                Text(formatterWithTime.string(from: endDateTime))
                            } else {
                                Text(formatter.string(from: endDate))
                            }
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(Color(0x000000, opacity: 0.5))
                }
            }

            Spacer()

            Button {
                checkListViewModel.updateFlag(todo) {}
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
