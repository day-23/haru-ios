//
//  SettingAlarmView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/10.
//

import SwiftUI

struct SettingAlarmView: View {
    @Environment(\.dismiss) var dismissAction
    @ObservedObject var settingAlarmViewModel: SettingAlarmViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
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

                        if settingAlarmViewModel.isMorningAlarmOn {
                            CustomDatePicker(
                                selection: $settingAlarmViewModel.morningAlarmTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding(.trailing, 16)
                        }

                        Toggle(isOn: $settingAlarmViewModel.isMorningAlarmOn.animation()) {}
                            .toggleStyle(CustomToggleStyle())
                    }
                    .frame(height: 25)

                    HStack(spacing: 0) {
                        Text("저녁 알림")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x191919))

                        Spacer()

                        if settingAlarmViewModel.isNightAlarmOn {
                            CustomDatePicker(
                                selection: $settingAlarmViewModel.nightAlarmTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding(.trailing, 16)
                        }

                        Toggle(isOn: $settingAlarmViewModel.isNightAlarmOn.animation()) {}
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
