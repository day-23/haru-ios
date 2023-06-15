//
//  TimeTableTodoView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import SwiftUI

struct TimeTableTodoView: View {
    // MARK: - Properties

    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

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
        if !UIDevice.current.name.contains("SE") {
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
                        dateFormatter.string(from: .now) == dateFormatter.string(from: timeTableViewModel.thisWeek[index])
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
        } else {
            ScrollView {
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
                            dateFormatter.string(from: .now) == dateFormatter.string(from: timeTableViewModel.thisWeek[index])
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
                        .frame(idealHeight: 72)
                    }
                    Spacer(minLength: 70)
                }
                .onAppear {
                    timeTableViewModel.fetchTodoList()
                }
            }
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

struct OverflowContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear.onAppear {
                            contentOverflow = contentGeometry.size.height > geometry.size.height
                        }
                    }
                )
                .wrappedInScrollView(when: contentOverflow)
        }
    }
}

extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool) -> some View {
        if condition {
            ScrollView {
                self
            }
        } else {
            self
        }
    }
}

extension View {
    func scrollOnOverflow() -> some View {
        modifier(OverflowContentViewModifier())
    }
}
