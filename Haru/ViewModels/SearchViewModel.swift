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

        if repeatValue.prefix(1) == "T" {
            let day = 60 * 60 * 24
            var repeatStart = schedule.repeatStart

            while repeatStart < Date() {
                do {
                    repeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: repeatStart)
                } catch {
                    print("[Error] nextRepeatStartDate의 계산 오류 \(#file) \(#function)")
                    return schedule
                }
            }

            var repeatEnd = repeatStart.addingTimeInterval(
                TimeInterval(
                    Double(
                        repeatValue.split(separator: "T")[0]
                    ) ?? 0
                )
            )

            let oriRepeatEnd: Date = repeatEnd
            if repeatOption == .everyMonth,
               repeatStart.month != repeatEnd.month
            {
                repeatEnd = CalendarHelper.makeDate(date: repeatStart, hour: 23, minute: 55)
            }

            do {
                let nextRepeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: repeatStart)
                var prevRepeatEnd: Date = repeatEnd

                switch repeatOption {
                case .everyDay:
                    break
                case .everyWeek:
                    prevRepeatEnd = repeatEnd.addingTimeInterval(TimeInterval(-day * 7))
                case .everySecondWeek:
                    prevRepeatEnd = repeatEnd.addingTimeInterval(TimeInterval(-day * 7 * 2))
                case .everyMonth:
                    prevRepeatEnd = CalendarHelper.prevMonthDate(curDate: oriRepeatEnd)
                case .everyYear:
                    prevRepeatEnd = CalendarHelper.prevYearDate(curDate: oriRepeatEnd)
                }

                return Schedule.createRepeatSchedule(
                    schedule: schedule,
                    repeatStart: repeatStart,
                    repeatEnd: repeatEnd,
                    prevRepeatEnd: prevRepeatEnd,
                    nextRepeatStart: nextRepeatStart
                )

            } catch {
                print("[Error] nextSucRepeatStartDate의 계산 오류 \(#file) \(#function)")
                return schedule
            }

        } else {
            var repeatStart = schedule.repeatStart
            var repeatEnd = CalendarHelper.makeDate(date: repeatStart, date2: schedule.repeatEnd)
            while repeatStart < Date() {
                do {
                    repeatStart = try schedule.nextRepeatStartDate(curRepeatStart: repeatStart)
                    repeatEnd = try schedule.nextRepeatStartDate(curRepeatStart: repeatEnd)
                } catch {
                    print("[Error] nextRepeatStartDate의 계산 오류 \(#file) \(#function)")
                    return schedule
                }
            }

            do {
                let prevRepeatEnd = try schedule.prevRepeatEndDate(curRepeatEnd: repeatEnd)
                let nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: repeatStart)

                return Schedule.createRepeatSchedule(
                    schedule: schedule,
                    repeatStart: repeatStart,
                    repeatEnd: repeatEnd,
                    prevRepeatEnd: prevRepeatEnd,
                    nextRepeatStart: nextRepeatStart
                )
            } catch {
                print("[Error] nextRepeatStartDate / prevRepeatEndDate의 계산 오류 \(#file) \(#function)")
                return schedule
            }
        }
    }
}
