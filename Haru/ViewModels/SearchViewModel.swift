//
//  SearchViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/06/03.
//

import Foundation
import UIKit

final class SearchViewModel: ObservableObject {
    @Published var scheduleList: [Schedule] = []
    @Published var todoList: [Todo] = []

    @Published var searchUser: User?

    private let searchService: SearchService = .init()
    private let friendService: FriendService = .init()
    private let profileService: ProfileService = .init()

    // MARK: - 이미지 캐싱

    func fetchProfileImage(
        profileUrl: String,
        completion: @escaping (PostImage) -> Void
    ) {
        DispatchQueue.global().async {
            if let uiImage = ImageCache.shared.object(forKey: profileUrl as NSString) {
                completion(PostImage(url: profileUrl, uiImage: uiImage))
            } else {
                guard
                    let encodeUrl = profileUrl.encodeUrl(),
                    let url = URL(string: encodeUrl),
                    let data = try? Data(contentsOf: url),
                    let uiImage = UIImage(data: data)
                else {
                    print("[Error] \(profileUrl)이 잘못됨 \(#fileID) \(#function)")
                    return
                }

                ImageCache.shared.setObject(uiImage, forKey: profileUrl as NSString)
                completion(PostImage(url: profileUrl, uiImage: uiImage))
            }
        }
    }

    // MARK: - 할일과 일정 검색

    func searchTodoAndSchedule(
        searchContent: String,
        completion: @escaping () -> Void
    ) {
        searchService.searchTodoAndSchedule(searchContent: searchContent) { result in
            switch result {
            case .success(let success):
                self.scheduleList = success.0.reduce([Schedule]()) { partialResult, schedule in
                    partialResult + [self.fittingSchedule(schedule: schedule)]
                }
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
        completion: @escaping () -> Void
    ) {
        searchService.searchUserWithHaruId(haruId: haruId) { result in
            switch result {
            case .success(let success):
                self.searchUser = success
            case .failure(let failure):
                self.searchUser = nil
                print("[Debug] \(haruId)를 사용하는 사용자는 없습니다.")
                print("\(failure) \(#file) \(#function)")
            }
            completion()
        }
    }

    func requestFriend(
        acceptorId: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.requestFriend(acceptorId: acceptorId) { result in
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
        friendService.acceptRequestFriend(requesterId: requesterId) { result in
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
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        friendService.cancelRequestFriend(acceptorId: acceptorId) { result in
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
        friendService.deleteFriend(friendId: friendId) { result in
            switch result {
            case .success:
                completion()
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }
}
