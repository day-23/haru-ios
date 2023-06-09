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
    var backgroundColor: Color = .white
    var at: RepeatAt = .front
    var isMiniCalendar: Bool = false
    var completeAction: () -> Void = {}
    var updateAction: () -> Void = {}

    // MARK: - API 호출시에 버튼을 비활성화 하는 변수들

    @State private var isCompletionButtonActive = true
    @State private var isToggleButtonActive = true
    @State private var isFlagButtonActive = true

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
        todo.tags.count > 0
            || todo.endDate != nil
            || todo.todayTodo
            || todo.alarms.count > 0
            || todo.repeatValue != nil
            || todo.repeatOption != nil
            || !todo.memo.isEmpty
    }

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d"
        return formatter
    }()

    let formatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if !todo.subTodos.isEmpty,
               !isMiniCalendar
            {
                Button {
                    isToggleButtonActive = false

                    checkListViewModel.updateFolded(todo: todo) { _ in
                        isToggleButtonActive = true
                    }
                } label: {
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .frame(width: 20, height: 28)
                        .rotationEffect(Angle(degrees: !todo.folded ? 90 : 0))
                        .foregroundColor(Color(0x646464, opacity: todo.completed ? 0.5 : 1))
                }
                .padding(.trailing, 6)
                .disabled(!isToggleButtonActive)
            }

            CompleteButton(isClicked: todo.completed)
                .onTapGesture {
                    isCompletionButtonActive = false

                    if (todo.repeatOption == nil && todo.repeatValue == nil)
                        || todo.completed
                    {
                        checkListViewModel.completeTodo(
                            todoId: todo.id,
                            completed: !todo.completed
                        ) { result in
                            switch result {
                            case .success:
                                completeAction()
                            case .failure(let failure):
                                print("[Debug] 반복하지 않는 할 일 완료 실패 \(failure) \(#fileID) \(#function)")
                            }
                        }
                        isCompletionButtonActive = true
                        return
                    }

                    do {
                        // 만약 반복이 끝났다면, nextEndDate == nil
                        guard let nextEndDate = try todo.nextEndDate() else {
                            // 반복이 끝났음
                            checkListViewModel.completeTodo(
                                todoId: todo.id,
                                completed: !todo.completed
                            ) { result in
                                switch result {
                                case .success:
                                    completeAction()
                                case .failure(let failure):
                                    print("[Debug] 반복하는 할 일 마지막 반복 완료 실패, \(failure) \(#fileID) \(#function)")
                                }
                            }
                            isCompletionButtonActive = true
                            return
                        }

                        // 반복이 끝나지 않음. (무한히 반복하는 할 일 or 반복 마감일 이전)
                        checkListViewModel.completeTodoWithRepeat(
                            todo: todo,
                            nextEndDate: nextEndDate,
                            at: at
                        ) { result in
                            switch result {
                            case .success:
                                completeAction()
                            case .failure(let failure):
                                print("[Debug] 반복하는 할 일 완료 실패, \(failure) \(#fileID) \(#function)")
                            }
                            isCompletionButtonActive = true
                        }
                    } catch {
                        switch error {
                        case RepeatError.invalid:
                            print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                        case RepeatError.calculation:
                            print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                        default:
                            print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                        }
                        isCompletionButtonActive = true
                    }
                }
                .padding(.leading, todo.subTodos.isEmpty && !isMiniCalendar ? 6 : 0)
                .padding(.trailing, 8)
                .disabled(!isCompletionButtonActive)

            VStack(alignment: .leading, spacing: 0) {
                Text(todo.content)
                    .multilineTextAlignment(.leading)
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
                            if formatter.string(from: .now) == formatter.string(from: todoDate),
                               todo.isAllDay
                            {
                                Text("\(formatterWithTime.string(from: todoDate))\(todo.repeatOption == nil ? " 까지" : "")")
                            } else {
                                Text("\(formatter.string(from: todoDate))\(todo.repeatOption == nil ? " 까지" : "")")
                            }
                        }

                        if (todo.tags.count > 0 || todo.endDate != nil)
                            && (todo.alarms.count > 0
                                || todo.todayTodo
                                || todo.repeatValue != nil
                                || todo.repeatOption != nil
                                || !todo.memo.isEmpty)
                        {
                            Image("todo-dot-small")
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                        }

                        if todo.todayTodo {
                            Image("todo-today-todo-small")
                                .renderingMode(.template)
                        }

                        if todo.alarms.count > 0 {
                            Image("todo-alarm-small")
                                .renderingMode(.template)
                        }

                        if todo.repeatValue != nil || todo.repeatOption != nil {
                            Image("todo-repeat-small")
                                .renderingMode(.template)
                        }

                        if !todo.memo.isEmpty {
                            Image("todo-memo-small")
                                .renderingMode(.template)
                        }
                    }
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundColor(!todo.completed ? Color(0x191919) : Color(0xacacac))
                }
            }
            .padding(.top, 4)

            Spacer()
            StarButton(isClicked: todo.flag)
                .onTapGesture {
                    isFlagButtonActive = false

                    checkListViewModel.updateFlag(todo: todo) { _ in
                        updateAction()
                        isFlagButtonActive = true
                    }
                }
                .disabled(!isFlagButtonActive)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, todo.subTodos.isEmpty && !isMiniCalendar ? 34 : 14)
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
    }
}
