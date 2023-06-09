//
//  SettingAlarmView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/10.
//

import SwiftUI

struct SettingAlarmView: View {
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var global: Global

    private let userService: UserService = .init()

    var body: some View {
        let isMorningAlarmOn: Binding<Bool> = .init {
            guard let user = global.user else {
                return false
            }
            return user.morningAlarmTime != nil
        } set: {
            if $0 {
                global.user?.morningAlarmTime = .now
            } else {
                global.user?.morningAlarmTime = nil
            }

            userService.updateMorningAlarmTime(time: global.user?.morningAlarmTime) { _ in }
        }

        let morningAlarmTime: Binding<Date> = .init {
            guard let user = global.user,
                  let time = user.morningAlarmTime
            else {
                return .now
            }
            return time
        } set: {
            global.user?.morningAlarmTime = $0
            userService.updateMorningAlarmTime(time: global.user?.morningAlarmTime) { _ in }
        }

        let isNightAlarmOn: Binding<Bool> = .init {
            guard let user = global.user else {
                return false
            }
            return user.nightAlarmTime != nil
        } set: {
            if $0 {
                global.user?.nightAlarmTime = .now
            } else {
                global.user?.nightAlarmTime = nil
            }
            userService.updateNightAlarmTime(time: global.user?.nightAlarmTime) { _ in }
        }

        let nightAlarmTime: Binding<Date> = .init {
            guard let user = global.user,
                  let time = user.nightAlarmTime
            else {
                return .now
            }
            return time
        } set: {
            global.user?.nightAlarmTime = $0
            userService.updateNightAlarmTime(time: global.user?.nightAlarmTime) { _ in }
        }

        return VStack(spacing: 0) {
            SettingHeader(header: "알림") {
                dismissAction.callAsFunction()
            }

            Divider()
                .padding(.vertical, 19)

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 19) {
                    Text("푸시 알림")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("아침 알림")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x191919))

                        Spacer()

                        if isMorningAlarmOn.wrappedValue {
                            CustomDatePicker(
                                selection: morningAlarmTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding(.trailing, 16)
                        }

                        Toggle(isOn: isMorningAlarmOn.animation()) {}
                            .toggleStyle(CustomToggleStyle())
                    }
                    .frame(height: 25)

                    HStack(spacing: 0) {
                        Text("저녁 알림")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x191919))

                        Spacer()

                        if isNightAlarmOn.wrappedValue {
                            CustomDatePicker(
                                selection: nightAlarmTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding(.trailing, 16)
                        }

                        Toggle(isOn: isNightAlarmOn.animation()) {}
                            .toggleStyle(CustomToggleStyle())
                    }
                    .frame(height: 25)
                }
                .padding(.leading, 10)
                .padding(.trailing, 4)

//                Divider()
//
//                VStack(alignment: .leading, spacing: 19) {
//                    Text("SNS")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .font(.pretendard(size: 16, weight: .bold))
//                        .foregroundColor(Color(0x191919))
//
//                    HStack(spacing: 0) {
//                        Text("좋아요 알림")
//                            .font(.pretendard(size: 16, weight: .regular))
//                            .foregroundColor(Color(0x191919))
//
//                        Spacer()
//
//                        Toggle(isOn:) {}
//                            .toggleStyle(CustomToggleStyle())
//                    }
//                    .frame(height: 25)
//
//                    HStack(spacing: 0) {
//                        Text("코멘트 알림")
//                            .font(.pretendard(size: 16, weight: .regular))
//                            .foregroundColor(Color(0x191919))
//
//                        Spacer()
//
//                        Toggle(isOn:) {}
//                            .toggleStyle(CustomToggleStyle())
//                    }
//                    .frame(height: 25)
//                }
//                .padding(.leading, 10)
//                .padding(.trailing, 4)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}
