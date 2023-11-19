//
//  SearchViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/06/03.
//

import Foundation
import SwiftUI
import UIKit

final class SearchViewModel: ObservableObject {
    @Published var scheduleList: [Schedule] = []
    @Published var todoList: [Todo] = []

    @Published var searchUser: User?

    // MARK: - 할일과 일정 검색

    func searchTodoAndSchedule(
        searchContent: String,
        completion: @escaping (Bool) -> Void
    ) {
        SearchService.searchTodoAndSchedule(searchContent: searchContent) { result in
            switch result {
            case .success(let success):
                withAnimation {
                    self.scheduleList = success.0.reduce([Schedule]()) { partialResult, schedule in
                        partialResult + [self.fittingSchedule(schedule: schedule)]
                    }
                    self.todoList = success.1
                }
                completion(success.0.isEmpty && success.1.isEmpty ? false : true)
            case .failure(let failure):
                completion(false)
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

            let repeatEndStartDate = CalendarHelper.makeDate(date: schedule.repeatEnd, date2: repeatStart)

            if repeatEndStartDate < Date() {
                while repeatStart < repeatEndStartDate {
                    var tmpRS: Date
                    do {
                        tmpRS = try schedule.nextSucRepeatStartDate(curRepeatStart: repeatStart)
                    } catch {
                        print("[Error] nextRepeatStartDate의 계산 오류 \(#file) \(#function)")
                        return schedule
                    }

                    if tmpRS >= repeatEndStartDate {
                        break
                    }

                    repeatStart = tmpRS
                }
            } else {
                while repeatStart < Date() {
                    do {
                        repeatStart = try schedule.nextSucRepeatStartDate(curRepeatStart: repeatStart)
                    } catch {
                        print("[Error] nextRepeatStartDate의 계산 오류 \(#file) \(#function)")
                        return schedule
                    }
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

            let repeatEndStartDate = CalendarHelper.makeDate(date: schedule.repeatEnd, date2: repeatStart)

            if repeatEndStartDate < Date() {
                while repeatStart < repeatEndStartDate {
                    var tmpRS: Date
                    var tmpRE: Date
                    do {
                        tmpRS = try schedule.nextRepeatStartDate(curRepeatStart: repeatStart)
                        tmpRE = try schedule.nextRepeatStartDate(curRepeatStart: repeatEnd)
                    } catch {
                        print("[Error] nextRepeatStartDate의 계산 오류 \(#file) \(#function)")
                        return schedule
                    }
                    if tmpRS >= repeatEndStartDate {
                        break
                    }

                    repeatStart = tmpRS
                    repeatEnd = tmpRE
                }

            } else {
                while repeatStart < Date() {
                    do {
                        repeatStart = try schedule.nextRepeatStartDate(curRepeatStart: repeatStart)
                        repeatEnd = try schedule.nextRepeatStartDate(curRepeatStart: repeatEnd)
                    } catch {
                        print("[Error] nextRepeatStartDate의 계산 오류 \(#file) \(#function)")
                        return schedule
                    }
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

    // MARK: - 사용자 검색

    func searchUserWithHaruId(
        haruId: String,
        completion: @escaping (Bool) -> Void
    ) {
        SearchService.searchUserWithHaruId(haruId: haruId) { result in
            switch result {
            case .success(let success):
                self.searchUser = success
                completion(true)
            case .failure(let failure):
                self.searchUser = nil
                completion(false)
                print("[Debug] \(haruId)를 사용하는 사용자는 없습니다.")
                print("\(failure) \(#file) \(#function)")
            }
        }
    }

    func requestFriend(
        acceptorId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        FriendService.requestFriend(acceptorId: acceptorId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func acceptRequestFriend(
        requesterId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        FriendService.acceptRequestFriend(requesterId: requesterId) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func cancelRequestFriend(
        acceptorId: String,
        isRefuse: Bool = true,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        FriendService.cancelRequestFriend(
            acceptorId: acceptorId,
            isRefuse: isRefuse
        ) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    // friendId: 삭제할 친구의 id
    func deleteFriend(friendId: String, completion: @escaping () -> Void) {
        FriendService.deleteFriend(friendId: friendId) { result in
            switch result {
            case .success:
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
