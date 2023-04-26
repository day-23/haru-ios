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
    var todo: Todo?

    @Published var content: String = ""

    @Published var flag: Bool = false

    @Published var subTodoList: [SubTodo] = []

    @Published var tag: String = ""
    @Published var tagList: [Tag] = []

    @Published var isTodayTodo: Bool = false

    @Published var endDate: Date = .init()
    var selectedEndDate: Date? {
        if isSelectedEndDate { return endDate }
        return nil
    }

    @Published var isSelectedEndDate: Bool = false {
        didSet {
            if !isSelectedEndDate && isSelectedRepeat {
                isSelectedRepeat = false
            }
        }
    }

    //  isAllDay : endDate에 시간을 포함하여 계산해야하는지에 대한 데이터
    @Published var isAllDay: Bool = false

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
    @Published var repeatDay: String = "1" {
        didSet {
            if mode == .edit {
                return
            }

            guard let interval = Int(repeatDay) else { return }

            let day = 60 * 60 * 24
            endDate = Date.now.addingTimeInterval(TimeInterval(day * interval))
        }
    }

    @Published var repeatWeek: [Day] = [Day(content: "일"), Day(content: "월"), Day(content: "화"),
                                        Day(content: "수"), Day(content: "목"), Day(content: "금"), Day(content: "토")]
    {
        didSet {
            if mode == .edit {
                return
            }

            var nextEndDate = isSelectedEndDate ? endDate : Date()
            let day = 60 * 60 * 24
            let calendar = Calendar.current
            let pattern = repeatWeek.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            var index = (calendar.component(.weekday, from: nextEndDate) - 1) % 7
            if repeatOption == .everyWeek {
                while !pattern[index] {
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                    index = (index + 1) % 7
                }

                endDate = nextEndDate
            } else if repeatOption == .everySecondWeek {
                if index == 0 {
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                }

                while !pattern[index] {
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                    index = (index + 1) % 7

                    if index == 0 {
                        nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                    }
                }

                endDate = nextEndDate
            }
        }
    }

    @Published var repeatMonth: [Day] = (1 ... 31).map { Day(content: "\($0)") } {
        didSet {
            if mode == .edit {
                return
            }

            var nextEndDate = isSelectedEndDate ? endDate : Date()
            let day = 60 * 60 * 24
            let calendar = Calendar.current
            let pattern = repeatMonth.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            let year = calendar.component(.year, from: nextEndDate)
            let month = calendar.component(.month, from: nextEndDate)

            let dateComponents = DateComponents(year: year, month: month)
            guard let dateInMonth = calendar.date(from: dateComponents),
                  let range = calendar.range(of: .day, in: .month, for: dateInMonth)
            else {
                return
            }

            let upperBound = range.upperBound - 1
            var index = (calendar.component(.day, from: nextEndDate) - 1) % upperBound
            while !pattern[index] {
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                index = (index + 1) % upperBound
            }

            endDate = nextEndDate
        }
    }

    @Published var repeatYear: [Day] = (1 ... 12).map { Day(content: "\($0)월") } {
        didSet {
            if mode == .edit {
                return
            }

            var nextEndDate = isSelectedEndDate ? endDate : Date()
            let calendar = Calendar.current
            let pattern = repeatYear.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            var index = (calendar.component(.month, from: nextEndDate) - 1) % 12
            while !pattern[index] {
                if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                    nextEndDate = next
                    index = (index + 1) % 12
                } else {
                    return
                }
            }

            endDate = nextEndDate
        }
    }

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
        return content.isEmpty
    }

    init(checkListViewModel: CheckListViewModel, mode: TodoAddMode = .add) {
        self.checkListViewModel = checkListViewModel
        self.mode = mode
    }

    //  MARK: - Create

    private func createTodoData() -> Request.Todo {
        return Request.Todo(
            content: content,
            memo: memo,
            todayTodo: isTodayTodo,
            flag: flag,
            endDate: selectedEndDate,
            isAllDay: isAllDay,
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

    func addSimpleTodo() {
        let alt = content
        clear()
        content = alt
        isTodayTodo = true

        checkListViewModel.addTodo(todo: createTodoData()) { result in
            switch result {
            case .success:
                self.clear()
                self.checkListViewModel.fetchTodoList()
            case let .failure(error):
                print("[Debug] \(error) (\(#fileID), \(#function))")
            }
        }
    }

    func createSubTodo() {
        subTodoList.append(
            SubTodo(
                id: UUID().uuidString,
                content: "",
                subTodoOrder: -1,
                completed: false
            )
        )
    }

    //  MARK: - Update

    func updateTodo(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let todoId = todo?.id else {
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
            if todo.repeatOption != RepeatOption.everyWeek.rawValue ||
                todo.repeatOption != RepeatOption.everyWeek.rawValue
            {
                return
            }

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
            if todo.repeatOption != RepeatOption.everyMonth.rawValue {
                return
            }

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
            if todo.repeatOption != RepeatOption.everyYear.rawValue {
                return
            }

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
        content = todo.content

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
        isSelectedEndDate = todo.endDate != nil
        isAllDay = todo.isAllDay

        alarm = !todo.alarms.isEmpty ? todo.alarms[0].time : .init()
        isSelectedAlarm = !todo.alarms.isEmpty

        repeatOption = .everyDay
        if let option = RepeatOption.allCases.first(where: { $0.rawValue == todo.repeatOption }) {
            repeatOption = option
        }
        isSelectedRepeat = todo.repeatOption != nil
        repeatEnd = todo.repeatEnd ?? .init()
        isSelectedRepeatEnd = todo.repeatEnd != nil
        repeatDay = isSelectedRepeat &&
            todo.repeatOption == RepeatOption.everyDay.rawValue
            ? (todo.repeatValue ?? "1") : "1"
        initRepeatWeek(todo: todo)
        initRepeatMonth(todo: todo)
        initRepeatYear(todo: todo)

        memo = todo.memo
    }

    //  MARK: - Remove

    func deleteTodo(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let todoId = todo?.id else {
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

    func deleteTodoWithRepeat(
        at: TodoService.RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        if at == .front {
            guard let todo else {
                print("[Debug] todo를 찾을 수 없습니다. (\(#fileID), \(#function))")
                return
            }

            do {
                guard let date = try todo.nextEndDate() else {
                    checkListViewModel.deleteTodo(
                        todoId: todo.id
                    ) { result in
                        switch result {
                        case .success:
                            completion(.success(true))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                    return
                }

                checkListViewModel.deleteTodoWithRepeat(
                    todoId: todo.id,
                    date: date,
                    at: at
                ) { result in
                    switch result {
                    case .success:
                        completion(.success(true))
                    case let .failure(error):
                        completion(.failure(error))
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
        } else if at == .middle {
            //  TODO: todo가 반복하는 할 일의 중간에 있는 경우,
        } else if at == .back {
            //  TODO: todo가 반복하는 할 일의 끝에 있는 경우,
        }
    }

    func removeSubTodo(index: Int) {
        subTodoList.remove(at: index)
    }

    func clear() {
        content = ""

        flag = false

        subTodoList = []

        tag = ""
        tagList = []
        isTodayTodo = false

        endDate = .init()
        isSelectedEndDate = false

        isAllDay = false

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
