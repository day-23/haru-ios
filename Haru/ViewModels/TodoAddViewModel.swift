//
//  TodoAddViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation
import SwiftUI

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

    private var isChangedEndDate = false
    @Published var endDate: Date = .init() {
        didSet {
            if isPreviousEndDateEqual {
                isChangedEndDate = false
            } else {
                isChangedEndDate = true
            }
            let day = endDate.day

            var newButtonDisabledList = Array(repeating: false, count: 12)
            if day == 30 {
                newButtonDisabledList[1] = true
            } else if day == 31 {
                newButtonDisabledList[1] = true
                newButtonDisabledList[3] = true
                newButtonDisabledList[5] = true
                newButtonDisabledList[8] = true
                newButtonDisabledList[10] = true
            }

            withAnimation {
                buttonDisabledList = newButtonDisabledList
            }

            if isSelectedRepeatEnd {
                if repeatEnd.compare(endDate) == .orderedAscending {
                    repeatEnd = endDate
                }
            }
        }
    }

    var selectedEndDate: Date? {
        if isSelectedEndDate { return endDate }
        return nil
    }

    @Published var buttonDisabledList: [Bool] = Array(repeating: false, count: 12)
    @Published var isSelectedEndDate: Bool = false {
        didSet {
            if !isSelectedEndDate && isSelectedRepeat {
                isSelectedRepeat = false
            }
        }
    }

    //  isAllDay : endDate에 시간을 포함하여 계산해야하는지에 대한 데이터
    //           : true -> 시간을 포함한다.
    //           : false -> 시간을 포함하지 않는다.
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
    @Published var isSelectedRepeatEnd: Bool = false {
        didSet {
            repeatEnd = endDate
        }
    }

    @Published var repeatDay: String = "1"
    @Published var repeatWeek: [Day] = [Day(content: "일"), Day(content: "월"), Day(content: "화"),
                                        Day(content: "수"), Day(content: "목"), Day(content: "금"), Day(content: "토")]
    {
        didSet {
            if mode == .edit {
                return
            }

            var nextEndDate: Date = .now
            if isChangedEndDate {
                nextEndDate = endDate
            }
            let day = 60 * 60 * 24
            let calendar = Calendar.current
            let pattern = repeatWeek.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            var index = (calendar.component(.weekday, from: nextEndDate) - 1) % 7
            if repeatOption == .everyWeek {
                while !pattern[index] {
                    index = (index + 1) % 7
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                }
            } else if repeatOption == .everySecondWeek {
                if index == 0 {
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                }

                while !pattern[index] {
                    index = (index + 1) % 7
                    nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))

                    if index == 0 {
                        nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day * 7))
                    }
                }
            }
            endDate = nextEndDate
        }
    }

    @Published var repeatMonth: [Day] = (1 ... 31).map { Day(content: "\($0)") } {
        didSet {
            if mode == .edit {
                return
            }

            var nextEndDate: Date = .now
            if isChangedEndDate {
                nextEndDate = endDate
            }
            let day = 60 * 60 * 24
            let calendar = Calendar.current
            let pattern = repeatMonth.map { $0.isClicked ? true : false }

            if pattern.filter({ $0 }).isEmpty {
                return
            }

            guard let range = calendar.range(of: .day, in: .month, for: nextEndDate) else {
                return
            }

            var upperBound = range.upperBound - 1
            var index = (calendar.component(.day, from: nextEndDate) - 1) % upperBound
            while !pattern[index] {
                index = (index + 1) % upperBound
                let month = nextEndDate.month
                nextEndDate = nextEndDate.addingTimeInterval(TimeInterval(day))
                if month != nextEndDate.month {
                    guard let range = calendar.range(of: .day, in: .month, for: nextEndDate) else {
                        return
                    }
                    upperBound = range.upperBound - 1
                }
            }

            endDate = nextEndDate
        }
    }

    @Published var repeatYear: [Day] = (1 ... 12).map { Day(content: "\($0)월") } {
        didSet {
            if mode == .edit {
                return
            }

            var nextEndDate: Date = .now
            if isChangedEndDate {
                nextEndDate = endDate
            }
            let calendar = Calendar.current
            let pattern = repeatYear.map { $0.isClicked ? true : false }
            if pattern.filter({ $0 }).isEmpty {
                return
            }

            let day = nextEndDate.day
            var index = (calendar.component(.month, from: nextEndDate) - 1) % 12
            while !pattern[index] {
                if let next = calendar.date(byAdding: .month, value: 1, to: nextEndDate) {
                    guard let range = calendar.range(of: .day, in: .month, for: next) else {
                        return
                    }

                    let upperBound = range.upperBound - 1
                    let components = DateComponents(
                        year: next.year,
                        month: next.month,
                        day: day <= upperBound ? day : upperBound,
                        hour: endDate.hour,
                        minute: endDate.minute
                    )
                    guard let altNext = calendar.date(from: components) else {
                        return
                    }

                    index = (index + 1) % 12
                    nextEndDate = altNext
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
                for (idx, v) in buttonDisabledList.enumerated() {
                    if v {
                        value[idx].isClicked = false
                    }
                }
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

    var isPreviousRepeatStateEqual: Bool {
        guard let todo else {
            return false
        }

        if isSelectedRepeat != (todo.repeatOption != nil) {
            return false
        }

        if !isSelectedRepeat {
            return true
        }

        guard let prevStateRepeatOption = todo.repeatOption,
              repeatOption.rawValue == prevStateRepeatOption
        else {
            return false
        }

        guard let repeatValue,
              let prevStateRepeatValue = todo.repeatValue,
              repeatValue == prevStateRepeatValue
        else {
            return false
        }

        if isSelectedRepeatEnd != (todo.repeatEnd != nil) {
            return false
        }

        if !isSelectedRepeatEnd {
            return true
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"

        guard let prevStateRepeatEnd = todo.repeatEnd,
              formatter.string(from: repeatEnd) == formatter.string(from: prevStateRepeatEnd)
        else {
            return false
        }

        return true
    }

    var isPreviousEndDateEqual: Bool {
        guard let todo else {
            return false
        }

        if isSelectedEndDate != (todo.endDate != nil) {
            return false
        }

        if !isSelectedEndDate {
            return true
        }

        guard let prevStateEndDate = todo.endDate else {
            return false
        }

        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            if isAllDay == true && isAllDay == todo.isAllDay {
                formatter.dateFormat = "yyyyMMddhhmm"
            } else {
                formatter.dateFormat = "yyyyMMdd"
            }
            return formatter
        }()
        return formatter.string(from: endDate) == formatter.string(from: prevStateEndDate)
    }

    var isPreviousStateEqual: Bool {
        guard let todo else {
            return false
        }

        return (todo.content == content &&
            todo.flag == flag &&
            todo.subTodos.elementsEqual(subTodoList, by: { lhs, rhs in
                lhs.id == rhs.id
            }) &&
            todo.tags.elementsEqual(tagList, by: { lhs, rhs in
                lhs.id == rhs.id
            }) &&
            todo.todayTodo == isTodayTodo &&
            isPreviousEndDateEqual &&
            isPreviousRepeatStateEqual &&
            todo.memo == memo)
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
                .map { $0.content },
            subTodosCompleted: mode == .add ? nil :
                (subTodoList.isEmpty ? [] : subTodoList.map { $0.completed })
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
        guard let todo else {
            print("[Debug] todo를 찾을 수 없습니다. (\(#fileID), \(#function))")
            return
        }

        checkListViewModel.updateTodo(
            todoId: todo.id,
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

    func updateTodoWithRepeat(
        at: TodoService.RepeatAt,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let todo else {
            print("[Debug] todo를 찾을 수 없습니다. (\(#fileID), \(#function))")
            return
        }

        //  Case front: endDate 계산하여 넘겨주기, 만약 다음 날짜가 없다면? 그냥 업데이트로 진행
        //  Case middle: endDate 계산하여 넘겨주기
        //  Case back: preRepeatEnd 계산하여 넘겨주기

        //  반복 할 일은 수정시에 반복 관련된 옵션은 null로 만들어 전달해야하기 때문에
        //  아래 옵션을 false로 변경한다.
        isSelectedRepeat = false
        if at == .front || at == .middle {
            do {
                guard let endDate = try todo.nextEndDate() else {
                    checkListViewModel.updateTodo(
                        todoId: todo.id,
                        todo: createTodoData()
                    ) { result in
                        switch result {
                        case let .success(success):
                            completion(.success(success))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                    return
                }

                checkListViewModel.updateTodoWithRepeat(
                    todoId: todo.id,
                    todo: createTodoData(),
                    date: endDate,
                    at: at
                ) { result in
                    switch result {
                    case let .success(success):
                        completion(.success(success))
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
        } else if at == .back {
            do {
                let prevRepeatEnd = try todo.prevEndDate()

                checkListViewModel.updateTodoWithRepeat(
                    todoId: todo.id,
                    todo: createTodoData(),
                    date: prevRepeatEnd,
                    at: at
                ) { result in
                    switch result {
                    case let .success(success):
                        completion(.success(success))
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

        isChangedEndDate = false
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
        guard let todo else {
            print("[Debug] todo를 찾을 수 없습니다. (\(#fileID), \(#function))")
            return
        }

        checkListViewModel.deleteTodo(todoId: todo.id) { result in
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
        guard let todo else {
            print("[Debug] todo를 찾을 수 없습니다. (\(#fileID), \(#function))")
            return
        }

        if at == .front || at == .middle {
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
        } else if at == .back {
            //  TODO: todo가 반복하는 할 일의 끝에 있는 경우,
            //  1. 무한히 반복하는 할 일의 경우 -> 이런 경우가 있는지에 대해 이야기 필요함
            //  2. 그냥 반복하는 할 일의 끝인 경우 -> repeatEnd를 전달.
            guard let todoRepeatEnd = todo.repeatEnd else {
                //  1번 케이스
                return
            }

            //  2번 케이스
            do {
                let repeatEnd = try todo.prevEndDate()

                checkListViewModel.deleteTodoWithRepeat(
                    todoId: todo.id,
                    date: repeatEnd,
                    at: .back
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

        isChangedEndDate = false
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
