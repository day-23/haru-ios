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
        regular: Regular
    ) {
        todoService.fetchTodoListByTodayTodoAndUntilToday { result in
            switch result {
            case .success(let data):
                var res = 0
                res += data.flaggedTodos.count
                res += data.todayTodos.count
                res += data.endDateTodos.filter { todo in
                    guard let endDate = todo.endDate else {
                        return false
                    }
                    return endDate.isEqual(other: .now)
                }.count

                let content = UNMutableNotificationContent()
                content.title = "하루"
                content.body = regular == .morning ? "오늘 할 일이 \(res)개 있습니다." : "오늘 남은 할 일이 \(res)개 있습니다."
                content.sound = .default

                let now = Date()
                var dateComponents = DateComponents()
                // TODO: 아침, 저녁으로 정해줘야 함.
                dateComponents.hour = now.hour
                dateComponents.minute = now.minute
                dateComponents.second = now.addingTimeInterval(regular == .morning ? 5 : 10).second
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: regular.rawValue, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("[Debug] 알림 예약 실패: \(error.localizedDescription)")
                        return
                    }

                    print("[Debug] \(regular) \(res) 알림 등록 완료")
                }
            case .failure:
                break
            }
        }
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

            print("[Debug] \"\(body)\" \(date) 등록 완료 id: \(identifier)-\(date)")
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
}
