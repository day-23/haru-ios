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

    @Published var todoContent: String = ""
    @Published var tag: String = ""
    @Published var tagList: [String] = []
    @Published var isTodayTodo: Bool = false
    @Published var flag: Bool = false
    @Published var isSelectedAlarm: Bool = false
    @Published var alarm: Date = .init()
    @Published var repeatOption: RepeatOption = .none
    @Published var isSelectedRepeat: Bool = false
    @Published var isSelectedEndDate: Bool = false
    @Published var isSelectedEndDateTime: Bool = false
    @Published var endDate: Date = .init()
    @Published var endDateTime: Date = .init()
    @Published var isSelectedRepeatEnd: Bool = false
    @Published var repeatEnd: Date = .init()
    @Published var isWritedMemo: Bool = false
    @Published var memo: String = ""
    @Published var days: [Day] = [
        Day(content: "월"),
        Day(content: "화"),
        Day(content: "수"),
        Day(content: "목"),
        Day(content: "금"),
        Day(content: "토"),
        Day(content: "일"),
    ]
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
        if selectedEndDate != nil && isSelectedEndDateTime { return endDateTime }
        return nil
    }

    var selectedRepeatEnd: Date? {
        if isSelectedRepeat && isSelectedRepeatEnd { return repeatEnd }
        return nil
    }

    init(checkListViewModel: CheckListViewModel) {
        self.checkListViewModel = checkListViewModel
    }

    // MARK: - Methods

    func addTodo(completion: @escaping (Result<Todo, Error>) -> Void) {
        checkListViewModel.addTodo(Request.Todo(
            content: todoContent,
            memo: isWritedMemo ? memo : "",
            todayTodo: isTodayTodo,
            flag: flag,
            endDate: selectedEndDate,
            endDateTime: selectedEndDateTime,
            alarms: selectedAlarm,
            repeatOption: repeatOption == .none ? nil : repeatOption.rawValue,
            repeatEnd: selectedRepeatEnd,
            repeat: repeatOption != .none || days.filter { day in
                day.isClicked
            }.isEmpty ? nil : days.reduce("") { acc, day in
                acc + (day.isClicked ? "1" : "0")
            },
            tags: tagList,
            subTodos: subTodoList.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        )) { result in
            switch result {
            case .success(let todo):
                completion(.success(todo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func createSubTodo() {
        subTodoList.append("")
    }

    func removeSubTodo(_ index: Int) {
        subTodoList.remove(at: index)
    }
}
