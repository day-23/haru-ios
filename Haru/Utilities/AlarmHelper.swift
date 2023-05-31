//
//  AlarmHelper.swift
//  Haru
//
//  Created by 최정민 on 2023/05/31.
//

import Foundation
import UserNotifications

final class AlarmHelper {
    enum Regular: String {
        case morning
        case evening
    }

    private init() {}
    static let todoService: TodoService = .init()
    static let current: AlarmHelper = .init()

    static func regularNotification(regular: Regular) {
        todoService.fetchTodoListByTodayTodoAndUntilToday { result in
            switch result {
            case .success(let data):
                var res = 0
                res += data.flaggedTodos.filter { $0.todayTodo }.count
                res += data.todayTodos.count
                res += data.endDateTodos.filter { todo in
                    guard let endDate = todo.endDate else {
                        return false
                    }
                    return endDate.isEqual(other: .now)
                }.count

                let content = UNMutableNotificationContent()
                content.title = "하루"
                content.body = (regular == .morning ? "오늘 할 일이 \(res)개 있습니다." : "오늘 남은 할 일이 \(res)개 있습니다.")
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
                        return
                    }
                }
            case .failure:
                break
            }
        }
    }

    static func scheduleNotification(
        body: String,
        date: Date,
        identifier: String
    ) {
        if date < .now {
            print("[Debug] 알람의 시간이 현재보다 이전이므로 알람을 등록하지 않습니다. \(date) < \(Date.now)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "하루"
        content.body = body
        content.sound = UNNotificationSound.default

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("[Debug] \(date), '\(body)' 알림 예약 완료")
            }
        }
    }

    static func scheduleRegularNotification(
        regular: Regular
    ) {
        if regular == .morning {
            let content = UNMutableNotificationContent()
            content.title = "하루"
            content.body = "아침 알람"
            content.sound = .default

            var dateComponents = DateComponents()
            let now = Date()
            dateComponents.hour = now.hour
            dateComponents.minute = now.minute
            dateComponents.second = now.addingTimeInterval(5).second
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: Regular.morning.rawValue, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
                } else {
                    print("[Debug] 아침 알림 등록")
                }
            }
        } else if regular == .evening {
            let content = UNMutableNotificationContent()
            content.title = "하루"
            content.body = "저녁 알람"
            content.sound = .default

            var dateComponents = DateComponents()
            let now = Date()
            dateComponents.hour = now.hour
            dateComponents.minute = now.minute
            dateComponents.second = now.addingTimeInterval(10).second
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: Regular.evening.rawValue, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
                } else {
                    print("[Debug] 저녁 알림 등록")
                }
            }
        }
    }

    static func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    static func hasNotification(identifier: String) async -> Bool {
        let notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return !notifications.filter { $0.identifier.hasPrefix(identifier) }.isEmpty
    }
}
