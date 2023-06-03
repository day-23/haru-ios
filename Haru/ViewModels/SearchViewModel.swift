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
            var day = 60 * 60 * 24
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

            var oriRepeatEnd: Date = repeatEnd
            if repeatOption == RepeatOption.everyMonth.rawValue,
               repeatStart.month != repeatEnd.month
            {
                repeatEnd = CalendarHelper.makeDate(date: repeatStart, hour: 23, minute: 55)
            }

            do {
                var nextRepeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: repeatStart)
                var prevRepeatEnd: Date
                switch repeatOption {
                case "매주":
                    prevRepeatEnd = repeatEnd.addingTimeInterval(TimeInterval(-day * 7))
                case "격주":
                    prevRepeatEnd = repeatEnd.addingTimeInterval(TimeInterval(-day * 7 * 2))
                case "매달":
                    prevRepeatEnd = CalendarHelper.prevMonthDate(curDate: oriRepeatEnd)
                case "매년":
                    prevRepeatEnd = CalendarHelper.prevYearDate(curDate: oriRepeatEnd)
                default:
                    prevRepeatEnd = Date()
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
                var prevRepeatEnd = try schedule.prevRepeatEndDate(curRepeatEnd: repeatEnd)
                var nextRepeatStart = try schedule.nextRepeatStartDate(curRepeatStart: repeatStart)

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
