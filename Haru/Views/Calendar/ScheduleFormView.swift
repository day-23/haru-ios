//
//  ScheduleFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import PopupView
import SwiftUI

struct ScheduleFormView: View {
    @Environment(\.dismiss) var dismissAction
    @StateObject var scheduleFormVM: ScheduleFormViewModel

    @Binding var isSchModalVisible: Bool

    @State private var showCategorySheet: Bool = false
    @State private var showingPopup: Bool = false

    @State private var selectedIdx: Int?
    
    var selectedIndex: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 일정 입력
                Group {
                    TextField("일정 입력", text: $scheduleFormVM.content)
                        .font(Font.system(size: 24, weight: .medium))
                        .padding(.horizontal, 30)
                    Divider()
                }
                
                // 카테고리 선택
                Group {
                    HStack {
                        if let selectIndex = scheduleFormVM.selectionCategory {
                            Circle()
                                .fill(Color(scheduleFormVM.categoryList[selectIndex].color, true))
                                .padding(5)
                                .frame(width: 28, height: 28)
                            
                            Button {
                                showCategorySheet = true
                            } label: {
                                Text("\(scheduleFormVM.categoryList[selectIndex].content)")
                                    .font(.pretendard(size: 14, weight: .medium))
                            }
                            .popup(isPresented: $showCategorySheet) {
                                CategoryView(scheduleFormVM: scheduleFormVM, selectedIdx: $selectedIdx)
                                    .background(Color.white)
                                    .frame(height: 450)
                                    .cornerRadius(20)
                                    .padding(.horizontal, 30)
                                    .shadow(radius: 2.0)
                                    .onAppear {
                                        selectedIdx = self.scheduleFormVM.selectionCategory
                                    }
                            } customize: {
                                $0
                                    .animation(.spring())
                                    .closeOnTap(false)
                                    .closeOnTapOutside(true)
                                    .dismissCallback {
                                        scheduleFormVM.selectionCategory = selectedIdx
                                    }
                            }
                            .tint(Color.black)
                        } else {
                            Image("check-circle")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.gray2)
                            
                            Button {
                                showCategorySheet = true
                            } label: {
                                Text("카테고리 선택")
                                    .font(.pretendard(size: 14, weight: .medium))
                            }
                            .popup(isPresented: $showCategorySheet) {
                                CategoryView(scheduleFormVM: scheduleFormVM, selectedIdx: $selectedIdx)
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
                                        scheduleFormVM.selectionCategory = selectedIdx
                                    }
                            }
                            .tint(Color.gray2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    Divider()
                }
                
                // 시작일, 종료일 설정
                Group {
                    Label {
                        Toggle(isOn: $scheduleFormVM.isAllDay.animation(), label: {
                            HStack {
                                Text("하루 종일")
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .frame(alignment: .leading)
                                Spacer()
                            }
                        })
                        .toggleStyle(MyToggleStyle())
                    } icon: {
                        Image(systemName: "clock")
                            .resizable()
                            .padding(6)
                            .frame(width: 28, height: 28)
                    }
                    .foregroundColor(scheduleFormVM.isAllDay ? .black : .gray2)
                    .padding(.horizontal, 20)

                    HStack {
                        VStack(alignment: .center) {
                            DatePicker(
                                "",
                                selection: $scheduleFormVM.repeatStart,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .transition(.picker)
                            
                            if !scheduleFormVM.isAllDay {
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
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            DatePicker(
                                "",
                                selection: $scheduleFormVM.repeatEnd,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .transition(.picker)
                            
                            if !scheduleFormVM.isAllDay {
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
                    }
                    .padding(.horizontal, 20)
                    .scaleEffect(0.8)
                    
                    Divider()
                }
                
                // 알람 설정
                Group {
                    Label {
                        Toggle(isOn: $scheduleFormVM.isSelectedAlarm.animation(), label: {
                            HStack {
                                Text("알림 설정")
                                    .font(.pretendard(size: 14, weight: .medium))
                                Spacer()
                            }
                        })
                        .toggleStyle(MyToggleStyle())
                    } icon: {
                        Image("bell")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .padding(.horizontal, 20)
                    .foregroundColor(scheduleFormVM.isSelectedAlarm ? .mainBlack : .gray2)
                    
                    if scheduleFormVM.isSelectedAlarm {
                        Picker("", selection: $scheduleFormVM.alarmOptions.animation()) {
                            ForEach(AlarmOption.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 55)
                        .padding(.vertical, 6)
                    }
                    Divider()
                }
                
                // 반복 설정
//                Group {
//                    Label {
//                        Toggle(isOn: $scheduleFormVM.repeatOption.animation(), label: {
//                            HStack {
//                                Text("반복 설정")
//                                    .font(.pretendard(size: 14, weight: .medium))
//                                Spacer()
//                            }
//                        })
//                        .toggleStyle(MyToggleStyle())
//                    } icon: {
//                        Image("repeat")
//                            .renderingMode(.template)
//                            .resizable()
//                            .frame(width: 28, height: 28)
//                    }
//                    .padding(.horizontal, 20)
//                    .foregroundColor(scheduleFormVM.repeatOption ? .mainBlack : .gray2)
//
//                    Divider()
//                }
                
                // 메모 추가
                Group {
                    Label {
                        HStack {
                            Text("메모 추가")
                                .font(.pretendard(size: 14, weight: .medium))
                            Spacer()
                        }
                    } icon: {
                        Image("memo")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .padding(.horizontal, 20)
                    .foregroundColor(scheduleFormVM.memo.isEmpty ? .gray2 : .mainBlack)

                    TextField("메모를 작성해주세요", text: $scheduleFormVM.memo, axis: .vertical)
                        .font(.pretendard(size: 14, weight: .medium))
                        .padding(.leading, 45)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    Divider()
                }
                
                Group {
                    HStack {
                        Button {
                            switch scheduleFormVM.mode {
                            case .add:
                                isSchModalVisible = false
                            case .edit:
                                scheduleFormVM.deleteSchedule()
                                dismissAction.callAsFunction()
                            }
                        } label: {
                            Text(scheduleFormVM.mode == .add ? "취소" : "삭제")
                                .font(.pretendard(size: 20, weight: .medium))
                        }
                        .tint(.mainBlack)
                        Spacer()
                        Button {
                            // TODO: 일정의 종료 시간이 일정의 시작 시간보다 빠르면 toast 알림창
                            switch scheduleFormVM.mode {
                            case .add:
                                scheduleFormVM.addSchedule()
                                isSchModalVisible = false
                            case .edit:
                                scheduleFormVM.updateSchedule()
                                dismissAction.callAsFunction()
                            }
                        } label: {
                            Text(scheduleFormVM.mode == .add ? "추가" : "저장")
                                .font(.pretendard(size: 20, weight: .medium))
                        }
                        .tint(.gradientStart1)
                    }
                    .padding(.horizontal, 80)
                }
            } // VStack
            .padding(.top, 30)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if !isSchModalVisible {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Image("back-button")
                            .frame(width: 28, height: 28)
                    }
                }
            }
        }
    }
}

// struct ScheduleFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleFormView(scheduleFormVM: ScheduleFormViewModel(calendarVM: CalendarViewModel()), isSchModalVisible: .constant(true))
//    }
// }
