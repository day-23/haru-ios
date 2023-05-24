//
//  TimeTableTodoView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import SwiftUI

struct TimeTableTodoView: View {
    // MARK: - Properties

    @StateObject var todoAddViewModel: TodoAddViewModel
    @StateObject var timeTableViewModel: TimeTableViewModel

    init(
        todoAddViewModel: StateObject<TodoAddViewModel>,
        timeTableViewModel: StateObject<TimeTableViewModel>
    ) {
        _todoAddViewModel = todoAddViewModel
        _timeTableViewModel = timeTableViewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                TimeTableTodoRow(
                    index: index,
                    date: timeTableViewModel.thisWeek[index],
                    todoList: $timeTableViewModel.todoListByDate[index],
                    timeTableViewModel: timeTableViewModel,
                    todoAddViewModel: todoAddViewModel
                )
                .background(
                    index == Date.now.indexOfWeek()
                        ? RadialGradient(
                            gradient: Gradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        ).opacity(0.5)
                        : RadialGradient(
                            colors: [.white],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        ).opacity(0.5)
                )
                .onDrop(of: [.text], delegate: TodoDropDelegate(
                    index: index,
                    timeTableViewModel: timeTableViewModel
                ))
            }
            Spacer()
        }
        .onAppear {
            timeTableViewModel.fetchTodoList()
        }
    }
}

struct TodoDropDelegate: DropDelegate {
    let index: Int
    let timeTableViewModel: TimeTableViewModel

    func dropEntered(info: DropInfo) {}

    func dropExited(info: DropInfo) {}

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }

    func performDrop(info: DropInfo) -> Bool {
        timeTableViewModel.updateDraggingTodo(
            index: index
        )
        return true
    }
}
