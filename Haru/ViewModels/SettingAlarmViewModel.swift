//
//  SettingAlarmViewModel.swift
//  Haru
//
//  Created by 최정민 on 12/16/23.
//

import Foundation

final class SettingAlarmViewModel: ObservableObject {
    @Published private var _isMorningAlarmOn: Bool
    var isMorningAlarmOn: Bool {
        get {
            return _isMorningAlarmOn
        }
        set(value) {
            _isMorningAlarmOn = value

            if value {
                Global.shared.user?.morningAlarmTime = .now
            } else {
                Global.shared.user?.morningAlarmTime = nil
            }

            if Global.shared.user?.morningAlarmTime != nil {
                UserService.updateMorningAlarmTime(time: Global.shared.user?.morningAlarmTime) { result in
                    switch result {
                    case .success:
                        AlarmHelper.createRegularNotification(regular: .morning, time: Global.shared.user?.morningAlarmTime ?? .now)
                    case .failure:
                        break
                    }
                }
            } else {
                Task {
                    await AlarmHelper.removeRegularNotification(regular: .morning)
                }
            }
        }
    }

    @Published private var _morningAlarmTime: Date
    var morningAlarmTime: Date {
        get {
            return _morningAlarmTime
        }
        set(value) {
            _morningAlarmTime = value

            if Global.shared.user?.morningAlarmTime != nil {
                UserService.updateMorningAlarmTime(time: Global.shared.user?.morningAlarmTime) { result in
                    switch result {
                    case .success:
                        AlarmHelper.createRegularNotification(regular: .morning, time: Global.shared.user?.morningAlarmTime ?? .now)
                    case .failure:
                        break
                    }
                }
            } else {
                Task {
                    await AlarmHelper.removeRegularNotification(regular: .morning)
                }
            }
        }
    }

    @Published private var _isNightAlarmOn: Bool
    var isNightAlarmOn: Bool {
        get {
            return _isNightAlarmOn
        }
        set(value) {
            _isNightAlarmOn = value

            if value {
                Global.shared.user?.nightAlarmTime = .now
            } else {
                Global.shared.user?.nightAlarmTime = nil
            }

            if Global.shared.user?.nightAlarmTime != nil {
                UserService.updateNightAlarmTime(time: Global.shared.user?.nightAlarmTime) { result in
                    switch result {
                    case .success:
                        AlarmHelper.createRegularNotification(regular: .evening, time: Global.shared.user?.nightAlarmTime ?? .now)
                    case .failure:
                        break
                    }
                }
            } else {
                Task {
                    await AlarmHelper.removeRegularNotification(regular: .evening)
                }
            }
        }
    }

    @Published private var _nightAlarmTime: Date
    var nightAlarmTime: Date {
        get {
            return _nightAlarmTime
        }
        set(value) {
            _nightAlarmTime = value

            if Global.shared.user?.nightAlarmTime != nil {
                UserService.updateNightAlarmTime(time: Global.shared.user?.nightAlarmTime) { result in
                    switch result {
                    case .success:
                        AlarmHelper.createRegularNotification(regular: .evening, time: Global.shared.user?.nightAlarmTime ?? .now)
                    case .failure:
                        break
                    }
                }
            } else {
                Task {
                    await AlarmHelper.removeRegularNotification(regular: .evening)
                }
            }
        }
    }

    init() {
        guard let user = Global.shared.user else {
            _isMorningAlarmOn = false
            _morningAlarmTime = .now
            _isNightAlarmOn = false
            _nightAlarmTime = .now
            return
        }

        _isMorningAlarmOn = user.morningAlarmTime != nil
        _morningAlarmTime = .now
        if let time = user.morningAlarmTime {
            _morningAlarmTime = time
        }
        _isNightAlarmOn = user.nightAlarmTime != nil
        _nightAlarmTime = .now
        if let time = user.nightAlarmTime {
            _nightAlarmTime = time
        }
    }
}
