//
//  ScheduleFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import PopupView
import SwiftUI

struct ScheduleFormView: View {
    @ObservedObject var scheduleFormVM: ScheduleFormViewModel
//    @Binding var categoryList: [Category]

    @State private var showCategorySheet: Bool = false

    @State private var idx: Int?
    @State private var showingPopup: Bool = false

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    print("close")
                } label: {
                    Image(systemName: "multiply")
                }

                Spacer()

                Button {
                    // TODO: 일정의 종료 시간이 일정의 시작 시간보다 빠르면 toast 알림창
                    scheduleFormVM.addSchedule()
                    print("complete")
                } label: {
                    Image(systemName: "checkmark")
                }
            }

            // 일정 입력
            Group {
                TextField("일정 입력", text: $scheduleFormVM.content)
                    .font(Font.system(size: 20, weight: .bold))
                Divider()
            }

            // 카테고리 선택
            Group {
                HStack {
                    if let selectIndex = scheduleFormVM.selectionCategory {
                        Circle()
                            .fill(Gradient(colors: [Constants.gradientStart,
                                                    Constants.gradientEnd]))
                            .overlay {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 20, height: 20)
                        Button("\(scheduleFormVM.categoryList[selectIndex].content)") {
                            showCategorySheet = true
                        }
                        .popup(isPresented: $showCategorySheet) {
                            CategoryView(
                                categoryList: $scheduleFormVM.categoryList,
                                selectionCategory: $idx
                            )
                            .background(Color.white)
                            .frame(height: 450)
                            .cornerRadius(20)
                            .padding(.horizontal, 30)
                            .shadow(radius: 2.0)
                        } customize: {
                            $0
                                .animation(.spring())
                                .closeOnTap(false)
                                .closeOnTapOutside(true)
                                .dismissCallback {
                                    scheduleFormVM.selectionCategory = idx
                                }
                        }
                        .tint(Color.black)
                    } else {
                        Circle()
                            .strokeBorder(Color.gray, lineWidth: 1)
                            .frame(width: 20, height: 20)

                        Button("카테고리 선택") {
                            showCategorySheet = true
                        }
                        .popup(isPresented: $showCategorySheet) {
                            CategoryView(
                                categoryList: $scheduleFormVM.categoryList,
                                selectionCategory: $idx
                            )
                            .background(Color.white)
                            .frame(height: 450)
                            .cornerRadius(20)
                            .padding(.horizontal, 30)
                            .shadow(radius: 2.0)
                        } customize: {
                            $0
                                .animation(.spring())
                                .closeOnTap(false)
                                .closeOnTapOutside(true)
                                .dismissCallback {
                                    scheduleFormVM.selectionCategory = idx
                                }
                        }
                        .tint(Color.gray)
                    }
                    Spacer()
                }
                Divider()
            }

            // 시작일, 종료일 설정
            Group {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("시작일-종료일 설정")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle(isOn: $scheduleFormVM.timeOption.animation()) {
                        Text("시간 설정")
                            .foregroundStyle(scheduleFormVM.timeOption ?
                                Gradient(colors: [Constants.gradientStart,
                                                  Constants.gradientEnd]) :
                                Gradient(colors: [.gray, .gray]))
                    }
                    .toggleStyle(MyToggleStyle())
                }

                HStack {
                    DatePicker(
                        "시작일",
                        selection: $scheduleFormVM.repeatStart,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)

                    if scheduleFormVM.timeOption {
                        DatePicker(
                            "",
                            selection: $scheduleFormVM.repeatStart,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .transition(.picker)
                    }
                }

                HStack {
                    DatePicker(
                        "종료일",
                        selection: $scheduleFormVM.repeatEnd,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)

                    if scheduleFormVM.timeOption {
                        DatePicker(
                            "",
                            selection: $scheduleFormVM.repeatEnd,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .transition(.picker)
                    }
                }

                Divider()
            }

            // 알람 설정
            Group {
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.gray)
                    Text("알림 설정")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle("", isOn: $scheduleFormVM.alarmOption.animation())
                        .toggleStyle(MyToggleStyle())
                }
                scheduleFormVM.alarmOption ? AnyView(DatePicker(
                    "알람일",
                    selection: $scheduleFormVM.alarmDate,
                    displayedComponents: [.date, .hourAndMinute]
                )) : AnyView(EmptyView())
                Divider()
            }

            // 반복 설정
            Group {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundStyle(.gray)
                    Text("반복 설정")
                        .foregroundColor(.gray)

                    Spacer()
                    Toggle("", isOn: $scheduleFormVM.repeatOption.animation())
                        .toggleStyle(MyToggleStyle())
                }
                Divider()
            }

            // 메모 추가
            Group {
                HStack {
                    Image(systemName: "doc")
                        .foregroundColor(.gray)

                    Text("메모 추가")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle("", isOn: $scheduleFormVM.memoOption.animation())
                        .toggleStyle(MyToggleStyle())
                }

                scheduleFormVM.memoOption ?
                    AnyView(TextField("메모 작성", text: $scheduleFormVM.memo, axis: .vertical)) :
                    AnyView(EmptyView())
                Divider()
            }
        } // VStack
        .padding(.horizontal)
    }
}

struct ScheduleFormView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleFormView(scheduleFormVM: ScheduleFormViewModel(calendarVM: CalendarViewModel()))
    }
}
