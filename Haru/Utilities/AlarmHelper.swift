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

    static func scheduleRegularNotification(
        regular: Regular
    ) {
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
                content.body = regular == .morning ? "오늘 할 일이 \(res)개 있습니다." : "오늘 남은 할 일이 \(res)개 있습니다."
                content.sound = UNNotificationSound.default

                let now = Date()
                var dateComponents = DateComponents()
                // TODO: 아침, 저녁으로 정해줘야 함.
                dateComponents.hour = now.hour
                dateComponents.minute = now.minute
                dateComponents.second = now.addingTimeInterval(regular == .morning ? 5 : 10).second
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
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

    static func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    static func hasNotification(identifier: String) async -> Bool {
        let notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return !notifications.filter { $0.identifier.hasPrefix(identifier) }.isEmpty
    }
}
