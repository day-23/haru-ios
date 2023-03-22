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
        //  Todo Item
        HStack {
            CompleteButton(isClicked: todo.completed)
                .onTapGesture {
                    if todo.repeatOption == nil &&
                        todo.repeatValue == nil
                    {
                        checkListViewModel.completeTodo(todoId: todo.id,
                                                        completed: !todo.completed) { result in
                            switch result {
                            case .success:
                                checkListViewModel.fetchTodoList()
                            case .failure(let failure):
                                print("[Debug] 반복하지 않는 할 일 완료 실패 \(failure) (\(#fileID), \(#function))")
                            }
                        }
                        return
                    }

                    do {
                        //  만약 반복이 끝났다면, nextEndDate == nil
                        guard let nextEndDate = try todo.nextEndDate() else {
                            //  반복이 끝났음
                            let data = Request.Todo(
                                content: todo.content,
                                memo: todo.memo,
                                todayTodo: todo.todayTodo,
                                flag: todo.flag,
                                endDate: nil,
                                isSelectedEndDateTime: todo.isSelectedEndDateTime,
                                alarms: todo.alarms.map { $0.time },
                                repeatOption: todo.repeatOption,
                                repeatValue: todo.repeatValue,
                                repeatEnd: todo.repeatEnd,
                                tags: todo.tags.map { $0.content },
                                subTodos: todo.subTodos.map { $0.content })

                            checkListViewModel.completeTodoWithRepeat(todoId: todo.id,
                                                                      todo: data) { result in
                                switch result {
                                case .success:
                                    checkListViewModel.fetchTodoList()
                                case .failure(let failure):
                                    print("[Debug] 반복하는 할 일 완료 실패, \(failure) (\(#fileID), \(#function))")
                                }
                            }
                            return
                        }

                        //  반복이 끝나지 않음. (무한히 반복하는 할 일 or 반복 마감일 이전)
                        let data = Request.Todo(
                            content: todo.content,
                            memo: todo.memo,
                            todayTodo: todo.todayTodo,
                            flag: todo.flag,
                            endDate: nextEndDate,
                            isSelectedEndDateTime: todo.isSelectedEndDateTime,
                            alarms: todo.alarms.map { $0.time },
                            repeatOption: todo.repeatOption,
                            repeatValue: todo.repeatValue,
                            repeatEnd: todo.repeatEnd,
                            tags: todo.tags.map { $0.content },
                            subTodos: todo.subTodos.map { $0.content })
                        checkListViewModel.completeTodoWithRepeat(todoId: todo.id,
                                                                  todo: data) { result in
                            switch result {
                            case .success:
                                checkListViewModel.fetchTodoList()
                            case .failure(let failure):
                                print("[Debug] 반복하는 할 일 완료 실패, \(failure) (\(#fileID), \(#function))")
                            }
                        }
                    } catch {
                        switch error {
                        case RepeatError.invalid:
                            print("[Debug] 입력 데이터에 문제가 있습니다. (\(#fileID), \(#function))")
                        case RepeatError.calculation:
                            print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. (\(#fileID), \(#function))")
                        default:
                            print("[Debug] 알 수 없는 오류입니다. (\(#fileID), \(#function))")
                        }
                    }
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.content)
                    .font(.body)
                    .strikethrough(todo.completed)

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
