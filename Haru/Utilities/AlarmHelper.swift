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
    private static let todoService: TodoService = .init()

    static func createRegularNotification(
        regular: Regular,
        time: Date
    ) {
        todoService.fetchTodoListByTodayTodoAndUntilToday { result in
            switch result {
            case .success(let data):
                var count = 0
                count += data.flaggedTodos.count
                count += data.todayTodos.count
                count += data.endDateTodos.filter { todo in
                    guard let endDate = todo.endDate else {
                        return false
                    }
                    return endDate.isEqual(other: .now)
                }.count

                let content = UNMutableNotificationContent()
                content.title = "하루"
                if count > 0 {
                    content.body = regular == .morning ? "오늘 할 일이 \(count)개 있습니다." : "오늘 남은 할 일이 \(count)개 있습니다."
                } else {
                    content.body = regular == .morning ? "오늘 해야할 일이 있나요?" : "오늘 할 일을 모두 마쳤나요?"
                }
                content.sound = .default

                var dateComponents = DateComponents()
                dateComponents.hour = time.hour
                dateComponents.minute = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: regular.rawValue, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
                        return
                    }

                    print("[Debug] \(regular) \(count) 알림 등록 완료")
                }
            case .failure:
                break
            }
        }
    }

    static func removeRegularNotification(regular: Regular) async {
        await removeNotification(identifier: regular.rawValue)
    }

    static func createNotification(
        identifier: String,
        body: String,
        date: Date
    ) async {
        if date <= .now {
            return
        }
        await removeNotification(identifier: identifier)

        let content = UNMutableNotificationContent()
        content.title = "하루"
        content.body = body
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(identifier)-\(date)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
                return
            }

//            print("[Debug] \"\(body)\" \(date) 등록 완료 id: \(identifier)-\(date)")
        }
    }

    static func removeNotification(identifier: String) async {
        let notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()

        var removed: [String] = []
        for notification in notifications {
            if notification.identifier.hasPrefix(identifier) {
                removed.append(notification.identifier)
            }
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: removed)
    }

    static func removeAllNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
