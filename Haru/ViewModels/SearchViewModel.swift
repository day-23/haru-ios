//
//  SearchViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/06/03.
//

import Foundation

final class SearchViewModel: ObservableObject {
    @Published var scheduleList: [Schedule] = []
    @Published var todoList: [Todo] = []

    private let searchService: SearchService = .init()

    func searchTodoAndSchedule(
        searchContent: String,
        completion: @escaping () -> Void
    ) {
        searchService.searchTodoAndSchedule(searchContent: searchContent) { result in
            switch result {
            case .success(let success):
                self.scheduleList = success.0
                self.todoList = success.1
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#file) \(#function)")
            }
        }
    }

    func fittingSchedule(schedule: Schedule) -> Schedule {
        guard let repeatOption = schedule.repeatOption,
              let repeatValue = schedule.repeatValue
        else {
            return schedule
        }

        return schedule
    }
}
