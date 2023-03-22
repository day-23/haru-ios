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

    @Published var flag: Bool = false

    @Published var subTodoList: [SubTodo] = []

    @Published var tag: String = ""
    @Published var tagList: [Tag] = []

    @Published var isTodayTodo: Bool = false

    @Published var endDate: Date = .init()
    @Published var endDateTime: Date = .init()
    @Published var isSelectedEndDate: Bool = false {
        didSet {
            if !isSelectedEndDate && isSelectedRepeat {
                isSelectedRepeat = false
            }
        }
    }

    @Published var isSelectedEndDateTime: Bool = false
    var selectedEndDate: Date? {
        if isSelectedEndDate { return endDate }
        return nil
    }

    var selectedEndDateTime: Date? {
        if selectedEndDate != nil &&
            isSelectedEndDateTime { return endDateTime }
        return nil
    }

    @Published var alarm: Date = .init()
    @Published var isSelectedAlarm: Bool = false
    var selectedAlarm: [Date] {
        if isSelectedAlarm { return [alarm] }
        return []
    }

    @Published var repeatOption: RepeatOption = .everyDay
    @Published var isSelectedRepeat: Bool = false {
        didSet {
            if isSelectedRepeat && !isSelectedEndDate {
                isSelectedEndDate = true
            }
        }
    }

    @Published var repeatEnd: Date = .init()
    @Published var isSelectedRepeatEnd: Bool = false
    @Published var repeatDay: String = "1"
    @Published var repeatWeek: [Day] = [Day(content: "일"), Day(content: "월"), Day(content: "화"),
                                        Day(content: "수"), Day(content: "목"), Day(content: "금"), Day(content: "토")]
    @Published var repeatMonth: [Day] = (1 ... 31).map { Day(content: "\($0)") }
    @Published var repeatYear: [Day] = (1 ... 12).map { Day(content: "\($0)월") }
    var selectedRepeatEnd: Date? {
        if isSelectedRepeat && isSelectedRepeatEnd { return repeatEnd }
        return nil
    }

    var repeatValue: String? {
        if isSelectedEndDate && isSelectedRepeat {
            var value: [Day] = []
            switch repeatOption {
            case .everyDay:
                return repeatDay
            case .everyWeek, .everySecondWeek:
                value = repeatWeek
            case .everyMonth:
                value = repeatMonth
            case .everyYear:
                value = repeatYear
            }
            return value.reduce("") { $0 + ($1.isClicked ? "1" : "0") }
        }
        return nil
    }

    @Published var memo: String = ""

    var isFieldEmpty: Bool {
        if isSelectedRepeat {
            switch repeatOption {
            case .everyDay:
                if repeatDay.isEmpty {
                    return true
                }
            case .everyWeek, .everySecondWeek:
                if repeatWeek.filter({ $0.isClicked }).isEmpty {
                    return true
                }
            case .everyMonth:
                if repeatMonth.filter({ $0.isClicked }).isEmpty {
                    return true
                }
            case .everyYear:
                if repeatYear.filter({ $0.isClicked }).isEmpty {
                    return true
                }
            }
        }
        return todoContent.isEmpty
    }

    init(checkListViewModel: CheckListViewModel, mode: TodoAddMode = .add) {
        self.checkListViewModel = checkListViewModel
        self.mode = mode
    }

    //  MARK: - Create

    private func createTodoData() -> Request.Todo {
        return Request.Todo(
            content: todoContent,
            memo: memo,
            todayTodo: isTodayTodo,
            flag: flag,
            endDate: selectedEndDate,
            isSelectedEndDateTime: isSelectedEndDateTime,
            alarms: selectedAlarm,
            repeatOption: !isSelectedEndDate || !isSelectedRepeat ? nil : repeatOption.rawValue,
            repeatValue: !isSelectedEndDate || !isSelectedRepeat ? nil : repeatValue,
            repeatEnd: !isSelectedEndDate || !isSelectedRepeat ? nil : selectedRepeatEnd,
            tags: tagList.map { $0.content },
            subTodos: subTodoList
                .filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .map { $0.content }
        )
    }

    func addTodo(
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        checkListViewModel.addTodo(todo: createTodoData()) { result in
            switch result {
            case let .success(todo):
                completion(.success(todo))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func createSubTodo() {
        subTodoList.append(SubTodo(id: UUID().uuidString,
                                   content: "",
                                   subTodoOrder: -1,
                                   completed: false))
    }

    //  MARK: - Update

    func updateTodo(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let todoId = todoId else {
            print("[Debug] todoId가 입력되지 않았습니다. (\(#fileID), \(#function))")
            return
        }

        checkListViewModel.updateTodo(
            todoId: todoId,
            todo: createTodoData()
        ) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func onChangeTag(_: String) {
        let trimTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty && tag[tag.index(tag.endIndex, offsetBy: -1)] == " " {
            if tagList.filter({ $0.content == trimTag }).isEmpty {
                tagList.append(Tag(id: UUID().uuidString, content: trimTag))
                tag = ""
            }
        }
    }

    func onSubmitTag() {
        let trimTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimTag.isEmpty {
            if tagList.filter({ $0.content == trimTag }).isEmpty {
                tagList.append(Tag(id: UUID().uuidString, content: trimTag))
                tag = ""
            }
        }
    }

    func toggleDay(repeatOption: RepeatOption, index: Int) {
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

    func initRepeatWeek(todo: Todo? = nil) {
        if let todo = todo {
            if let todoRepeatWeek = todo.repeatValue {
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

    func initRepeatMonth(todo: Todo? = nil) {
        if let todo = todo {
            if let todoRepeatMonth = todo.repeatValue {
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

    func initRepeatYear(todo: Todo? = nil) {
        if let todo = todo {
            if let todoRepeatYear = todo.repeatValue {
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

    func applyTodoData(todo: Todo) {
        todoContent = todo.content

        flag = todo.flag

        subTodoList = todo.subTodos.map {
            SubTodo(id: $0.id,
                    content: $0.content,
                    subTodoOrder: $0.subTodoOrder,
                    completed: $0.completed)
        }

        tag = ""
        tagList = todo.tags.map { Tag(id: $0.id, content: $0.content) }

        isTodayTodo = todo.todayTodo

        endDate = todo.endDate ?? .init()
        endDateTime = todo.endDateTime ?? .init()
        isSelectedEndDate = todo.endDate != nil
        isSelectedEndDateTime = todo.endDateTime != nil

        alarm = !todo.alarms.isEmpty ? todo.alarms[0].time : .init()
        isSelectedAlarm = !todo.alarms.isEmpty

        repeatOption = .everyDay
        if let option = RepeatOption.allCases.first(where: { $0.rawValue == todo.repeatOption }) {
            repeatOption = option
        }
        isSelectedRepeat = todo.repeatOption != nil
        repeatEnd = todo.repeatEnd ?? .init()
        isSelectedRepeatEnd = todo.repeatEnd != nil
        repeatDay = isSelectedRepeat ? (todo.repeatValue ?? "1") : "1"
        initRepeatWeek(todo: todo)
        initRepeatMonth(todo: todo)
        initRepeatYear(todo: todo)

        memo = todo.memo
    }

    //  MARK: - Remove

    func deleteTodo(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let todoId = todoId else {
            print("[Debug] todoID가 없습니다. (\(#fileID), \(#function))")
            return
        }

        checkListViewModel.deleteTodo(todoId: todoId) { result in
            switch result {
            case .success:
                completion(.success(true))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    func removeSubTodo(index: Int) {
        subTodoList.remove(at: index)
    }

    func clear() {
        todoContent = ""

        flag = false

        subTodoList = []

        tag = ""
        tagList = []
        isTodayTodo = false

        endDate = .init()
        endDateTime = .init()
        isSelectedEndDate = false
        isSelectedEndDateTime = false

        alarm = .init()
        isSelectedAlarm = false

        repeatOption = .everyDay
        isSelectedRepeat = false
        repeatEnd = .init()
        isSelectedRepeatEnd = false
        repeatDay = "1"
        initRepeatWeek()
        initRepeatMonth()
        initRepeatYear()

        memo = ""
    }
}
