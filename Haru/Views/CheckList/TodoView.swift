//
//  TodoItem.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct TodoView: View {
    @State private var disabled = false
    var checkListViewModel: CheckListViewModel
    var todo: Todo
    var backgroundColor: Color = .white

    private var tagString: String {
        var res = ""
        for (i, tag) in zip(todo.tags.indices, todo.tags) {
            if tag.content.count + res.count <= 10 {
                res = "\(res) \(tag.content)"
            } else {
                res = "\(res)  +\(todo.tags.count - i)"
            }
        }
        res = "\(res)  "
        return res
    }

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 까지"
        return formatter
    }()

    let formatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm 까지"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 0) {
            if !todo.subTodos.isEmpty {
                Button {
                    checkListViewModel.toggleShowingSubtodo(todoId: todo.id)
                } label: {
                    Image("toggle")
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: todo.isShowingSubTodo ? 90 : 0))
                }
            }

            CompleteButton(isClicked: todo.completed)
                .onTapGesture {
                    disabled = true

                    if (todo.repeatOption == nil &&
                        todo.repeatValue == nil) || todo.completed
                    {
                        checkListViewModel.completeTodo(todoId: todo.id,
                                                        completed: !todo.completed) { result in
                            switch result {
                            case .success:
                                successCompletion(todoId: todo.id)
                            case .failure(let failure):
                                print("[Debug] 반복하지 않는 할 일 완료 실패 \(failure) (\(#fileID), \(#function))")
                            }
                            disabled = false
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
                                    successCompletion(todoId: todo.id)
                                case .failure(let failure):
                                    print("[Debug] 반복하는 할 일 완료 실패, \(failure) (\(#fileID), \(#function))")
                                }
                                disabled = false
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
                                successCompletion(todoId: todo.id)
                            case .failure(let failure):
                                print("[Debug] 반복하는 할 일 완료 실패, \(failure) (\(#fileID), \(#function))")
                            }
                            disabled = false
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
                        disabled = false
                    }
                }
                .padding(.trailing, 14)
                .disabled(disabled)

            VStack(alignment: .leading, spacing: 0) {
                Text(todo.content)
                    .font(.system(size: 14, weight: .bold))
                    .strikethrough(todo.completed)

                if todo.tags.count > 0 ||
                    todo.endDate != nil ||
                    todo.endDateTime != nil ||
                    todo.todayTodo ||
                    todo.alarms.count > 0 ||
                    todo.repeatValue != nil ||
                    todo.repeatOption != nil ||
                    !todo.memo.isEmpty
                {
                    HStack(spacing: 0) {
                        Text(tagString)

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
                                todo.todayTodo ||
                                todo.repeatValue != nil ||
                                todo.repeatOption != nil ||
                                !todo.memo.isEmpty)
                        {
                            Image("dot")
                        }

                        if todo.todayTodo {
                            Image("today-todo-small")
                        }

                        if todo.alarms.count > 0 {
                            Image("alarm-small")
                        }

                        if todo.repeatValue != nil || todo.repeatOption != nil {
                            Image("repeat-small")
                        }

                        if !todo.memo.isEmpty {
                            Image("memo-small")
                        }
                    }
                    .padding(.leading, -4)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(0x000000, opacity: 0.5))
                }
            }

            Spacer()

            StarButton(isClicked: todo.flag)
                .onTapGesture {
                    checkListViewModel.updateFlag(todo: todo) { _ in }
                }
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .padding(.leading, todo.subTodos.isEmpty ? 34 : 14)
        .padding(.trailing, 20)
        .background(backgroundColor)
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

    func successCompletion(todoId: String) {
        checkListViewModel.toggleCompleted(todoId: todoId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkListViewModel.fetchTodoList()
        }
    }
}
