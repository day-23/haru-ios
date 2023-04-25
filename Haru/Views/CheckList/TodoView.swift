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
        if todo.tags.isEmpty {
            return ""
        }

        var res = ""
        for (i, tag) in zip(todo.tags.indices, todo.tags) {
            if tag.content.count + res.count <= 8 {
                if res.isEmpty {
                    res = "\(tag.content)"
                } else {
                    res = "\(res) \(tag.content)"
                }
            } else {
                res = "\(res)  +\(todo.tags.count - i)"
                break
            }
        }
        res = "\(res)"
        return res
    }

    private var showExtraInfo: Bool {
        todo.tags.count > 0 ||
            todo.endDate != nil ||
            todo.todayTodo ||
            todo.alarms.count > 0 ||
            todo.repeatValue != nil ||
            todo.repeatOption != nil ||
            !todo.memo.isEmpty
    }

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일까지"
        return formatter
    }()

    let formatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm까지"
        return formatter
    }()

    let formatterWithRepeat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter
    }()

    let formatterWithTimeAndRepeat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter
    }()

    var body: some View {
        HStack(alignment: showExtraInfo ? .top : .center, spacing: 0) {
            if !todo.subTodos.isEmpty {
                Button {
                    checkListViewModel.updateFolded(todo: todo) { _ in }
                } label: {
                    Image("toggle")
                        .renderingMode(.template)
                        .frame(width: 20, height: 28)
                        .rotationEffect(Angle(degrees: !todo.folded ? 90 : 0))
                        .foregroundColor(Color(0x646464, opacity: todo.completed ? 0.5 : 1))
                }
                .padding(.trailing, 6)
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
                        }
                        return
                    }

                    do {
                        //  만약 반복이 끝났다면, nextEndDate == nil
                        guard let nextEndDate = try todo.nextEndDate() else {
                            //  반복이 끝났음
                            //  !!!: - 반복이 끝났을 때 어떠한 데이터를 넘겨줘야하는지에 대해서 정보가 없음. -> 민재형한테 물어보기
                            checkListViewModel.completeTodoWithRepeat(
                                todoId: todo.id,
                                nextEndDate: .now, // 반복이 끝났을 때 어떠한 데이터를 넘겨줘야 함.
                                at: .front
                            ) { result in
                                switch result {
                                case .success:
                                    successCompletion(todoId: todo.id)
                                case .failure(let failure):
                                    print("[Debug] 반복하는 할 일 완료 실패, \(failure) (\(#fileID), \(#function))")
                                }
                            }
                            return
                        }

                        //  반복이 끝나지 않음. (무한히 반복하는 할 일 or 반복 마감일 이전)
                        checkListViewModel.completeTodoWithRepeat(
                            todoId: todo.id,
                            nextEndDate: nextEndDate,
                            at: .front
                        ) { result in
                            switch result {
                            case .success:
                                successCompletion(todoId: todo.id)
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
                        disabled = false
                    }
                }
                .padding(.leading, todo.subTodos.isEmpty ? 6 : 0)
                .padding(.trailing, 8)
                .disabled(disabled)

            VStack(alignment: .leading, spacing: 0) {
                Text(todo.content)
                    .font(.pretendard(size: 16, weight: .bold))
                    .strikethrough(todo.completed)
                    .foregroundColor(!todo.completed ? Color(0x191919) : Color(0xacacac))

                if showExtraInfo {
                    HStack(spacing: 0) {
                        if !tagString.isEmpty {
                            Text(tagString)
                                .frame(alignment: .leading)
                            Text("  ")
                        }

                        if let todoDate = todo.endDate {
                            if todo.isAllDay {
                                if todo.repeatOption == nil {
                                    Text(formatterWithTime.string(from: todoDate))
                                } else {
                                    Text(formatterWithTimeAndRepeat.string(from: todoDate))
                                }
                            } else {
                                if todo.repeatOption == nil {
                                    Text(formatter.string(from: todoDate))
                                } else {
                                    Text(formatterWithRepeat.string(from: todoDate))
                                }
                            }
                        }

                        if (todo.tags.count > 0 ||
                            todo.endDate != nil) &&
                            (todo.alarms.count > 0 ||
                                todo.todayTodo ||
                                todo.repeatValue != nil ||
                                todo.repeatOption != nil ||
                                !todo.memo.isEmpty)
                        {
                            Image("dot-small")
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                        }

                        if todo.todayTodo {
                            Image("today-todo-small")
                                .renderingMode(.template)
                        }

                        if todo.alarms.count > 0 {
                            Image("alarm-small")
                                .renderingMode(.template)
                        }

                        if todo.repeatValue != nil || todo.repeatOption != nil {
                            Image("repeat-small")
                                .renderingMode(.template)
                        }

                        if !todo.memo.isEmpty {
                            Image("memo-small")
                                .renderingMode(.template)
                        }
                    }
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundColor(!todo.completed ? Color(0x191919) : Color(0xacacac))
                }
            }

            Spacer()
            StarButton(isClicked: todo.flag)
                .onTapGesture {
                    checkListViewModel.updateFlag(todo: todo) { _ in }
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, todo.subTodos.isEmpty ? 34 : 14)
        .padding(.trailing, 20)
        .background(backgroundColor)
        .overlay(content: {
            GeometryReader { proxy in
                Color.clear.onAppear {
                    checkListViewModel.todoListOffsetMap = checkListViewModel.todoListOffsetMap.merging([(todo.id, proxy.frame(in: .global).midY)], uniquingKeysWith: { first, _ in
                        first
                    })
                }
                .frame(height: 0)
            }
        })
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
            disabled = false
        }
    }
}
