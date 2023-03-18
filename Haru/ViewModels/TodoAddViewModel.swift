//
//  TodoAddViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation

final class TodoAddViewModel: ObservableObject {
    // MARK: - Properties

    private let checkListViewModel: CheckListViewModel
    var mode: TodoAddMode
    var todoId: String?

    @Published var todoContent: String = ""
    @Published var tag: String = ""
    @Published var tagList: [String] = []
    @Published var isTodayTodo: Bool = false
    @Published var flag: Bool = false
    @Published var isSelectedAlarm: Bool = false
    @Published var alarm: Date = .init()
    @Published var repeatOption: RepeatOption = .everyDay
    @Published var isSelectedRepeat: Bool = false
    @Published var isSelectedEndDate: Bool = false
    @Published var isSelectedEndDateTime: Bool = false
    @Published var endDate: Date = .init()
    @Published var endDateTime: Date = .init()
    @Published var isSelectedRepeatEnd: Bool = false
    @Published var repeatEnd: Date = .init()
    @Published var isWritedMemo: Bool = false
    @Published var memo: String = ""
    @Published var repeatWeek: [Day] = [
        Day(content: "일"),
        Day(content: "월"),
        Day(content: "화"),
        Day(content: "수"),
        Day(content: "목"),
        Day(content: "금"),
        Day(content: "토")
    ]
    @Published var repeatMonth: [Day] = (1 ... 31).map { Day(content: "\($0)") }
    @Published var repeatYear: [Day] = (1 ... 12).map { Day(content: "\($0)월") }
    @Published var subTodoList: [String] = []

    var selectedAlarm: [Date] {
        if isSelectedAlarm { return [alarm] }
        return []
    }

    var selectedEndDate: Date? {
        if isSelectedEndDate { return endDate }
        return nil
    }

    var selectedEndDateTime: Date? {
        if selectedEndDate != nil &&
            isSelectedEndDateTime { return endDateTime }
        return nil
    }

    var selectedRepeatEnd: Date? {
        if isSelectedRepeat && isSelectedRepeatEnd { return repeatEnd }
        return nil
    }

    init(checkListViewModel: CheckListViewModel, mode: TodoAddMode = .add) {
        self.checkListViewModel = checkListViewModel
        self.mode = mode
    }

    // MARK: - Methods

    private func createTodoData() -> Request.Todo {
        return Request.Todo(
            content: todoContent,
            memo: isWritedMemo ? memo : "",
            todayTodo: isTodayTodo,
            flag: flag,
            endDate: selectedEndDate,
            endDateTime: selectedEndDateTime,
            alarms: selectedAlarm,
            repeatOption: !isSelectedRepeat ? nil : repeatOption.rawValue,
            repeatEnd: selectedRepeatEnd,
            repeatWeek: !isSelectedRepeat || (repeatOption != .everyWeek && repeatOption != .everySecondWeek) ||
                repeatWeek.filter { day in
                    day.isClicked
                }.isEmpty ? nil : repeatWeek.reduce("") { acc, day in
                    acc + (day.isClicked ? "1" : "0")
                },
            repeatMonth: !isSelectedRepeat || repeatOption != .everyMonth ||
                repeatMonth.filter { $0.isClicked }.isEmpty ?
                nil : repeatMonth.reduce("") { acc, day in
                    acc + (day.isClicked ? "1" : "0")
                },
            repeatYear: !isSelectedRepeat || repeatOption != .everyYear ||
                repeatYear.filter { $0.isClicked }.isEmpty ?
                nil : repeatYear.reduce("") { acc, day in
                    acc + (day.isClicked ? "1" : "0")
                },
            tags: tagList,
            subTodos: subTodoList
                .filter {
                    !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
        )
    }

    func addTodo(completion: @escaping (Result<Todo, Error>) -> Void) {
        checkListViewModel.addTodo(createTodoData()) { result in
            switch result {
            case let .success(todo):
                completion(.success(todo))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateTodo(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let todoId = todoId else {
            print("[Debug] todoId가 입력되지 않았습니다. (\(#fileID), \(#function))")
            return
        }

        checkListViewModel.updateTodo(
            todoId,
            createTodoData()
        ) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func createSubTodo() {
        subTodoList.append("")
    }

    func removeSubTodo(_ index: Int) {
        subTodoList.remove(at: index)
    }

    func onChangeTag(_: String) {
        let trimTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty && tag[tag.index(tag.endIndex, offsetBy: -1)] == " " {
            if !tagList.contains(trimTag) {
                tagList.append(trimTag)
                tag = ""
            }
        }
    }

    func onSubmitTag() {
        let trimTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty {
            if !tagList.contains(trimTag) {
                tagList.append(trimTag)
                tag = ""
            }
        }
    }

    func toggleDay(_ repeatOption: RepeatOption, index: Int) {
        switch repeatOption {
        case .everyDay:
            break
        case .everyWeek, .everySecondWeek:
            repeatWeek[index].isClicked.toggle()
        case .everyMonth:
            repeatMonth[index].isClicked.toggle()
        case .everyYear:
            repeatYear[index].isClicked.toggle()
        }
    }

    func initRepeatWeek(_ todo: Todo? = nil) {
        if let todo = todo {
            if let todoRepeatWeek = todo.repeatWeek {
                for i in repeatWeek.indices {
                    repeatWeek[i].isClicked = todoRepeatWeek[
                        todoRepeatWeek.index(todoRepeatWeek.startIndex, offsetBy: i)
                    ] == "0" ? false : true
                }
            } else {
                for i in repeatWeek.indices {
                    repeatWeek[i].isClicked = false
                }
            }
        } else {
            for i in repeatWeek.indices {
                repeatWeek[i].isClicked = false
            }
        }
    }

    func initRepeatMonth(_ todo: Todo? = nil) {
        if let todo = todo {
            if let todoRepeatMonth = todo.repeatMonth {
                for i in repeatMonth.indices {
                    repeatMonth[i].isClicked = todoRepeatMonth[
                        todoRepeatMonth.index(todoRepeatMonth.startIndex, offsetBy: i)
                    ] == "0" ? false : true
                }
            } else {
                for i in repeatMonth.indices {
                    repeatMonth[i].isClicked = false
                }
            }
        } else {
            for i in repeatMonth.indices {
                repeatMonth[i].isClicked = false
            }
        }
    }

    func initRepeatYear(_ todo: Todo? = nil) {
        if let todo = todo {
            if let todoRepeatYear = todo.repeatYear {
                for i in repeatYear.indices {
                    repeatYear[i].isClicked = todoRepeatYear[
                        todoRepeatYear.index(todoRepeatYear.startIndex, offsetBy: i)
                    ] == "0" ? false : true
                }
            } else {
                for i in repeatYear.indices {
                    repeatYear[i].isClicked = false
                }
            }
        } else {
            for i in repeatYear.indices {
                repeatYear[i].isClicked = false
            }
        }
    }

    func applyTodoData(_ todo: Todo) {
        todoContent = todo.content
        tag = ""
        tagList = todo.tags.map { $0.content }
        isTodayTodo = todo.todayTodo
        flag = todo.flag
        isSelectedAlarm = !todo.alarms.isEmpty
        alarm = !todo.alarms.isEmpty ? todo.alarms[0].time : .init()
        repeatOption = todo.repeatOption != nil ? RepeatOption.allCases
            .filter { $0.rawValue == todo.repeatOption }[0] : .everyDay
        isSelectedRepeat = todo.repeatOption != nil
        isSelectedEndDate = todo.endDate != nil
        isSelectedEndDateTime = todo.endDateTime != nil
        endDate = todo.endDate ?? .init()
        endDateTime = todo.endDateTime ?? .init()
        isSelectedRepeatEnd = todo.repeatEnd != nil
        repeatEnd = todo.repeatEnd ?? .init()
        isWritedMemo = !todo.memo.isEmpty
        memo = todo.memo
        initRepeatWeek(todo)
        initRepeatMonth(todo)
        initRepeatYear(todo)
        subTodoList = todo.subTodos.map { $0.content }
    }

    func clear() {
        todoContent = ""
        tag = ""
        tagList = []
        isTodayTodo = false
        flag = false
        isSelectedAlarm = false
        alarm = .init()
        repeatOption = .everyDay
        isSelectedRepeat = false
        isSelectedEndDate = false
        isSelectedEndDateTime = false
        endDate = .init()
        endDateTime = .init()
        isSelectedRepeatEnd = false
        repeatEnd = .init()
        isWritedMemo = false
        initRepeatWeek()
        initRepeatMonth()
        initRepeatYear()
        subTodoList = []
        memo = ""
    }
}
