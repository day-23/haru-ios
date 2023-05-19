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

    @Binding var isSchModalVisible: Bool // 일정 추가하는 경우 true

    @State private var showCategorySheet: Bool = false
    @State private var showingPopup: Bool = false

    @State private var selectedIdx: Int?
    
    @State var showDeleteActionSheet: Bool = false
    @State var showEditActionSheet: Bool = false
    @State var actionSheetOption: ActionSheetOption = .isNotRepeat
        
    enum ActionSheetOption {
        case isRepeat
        case isNotRepeat
    }

    var body: some View {
        VStack(spacing: 0) {
            if scheduleFormVM.mode == .add {
                HStack {
                    Button {
                        withAnimation {
                            isSchModalVisible = false
                        }
                    } label: {
                        Image("cancel")
                            .resizable()
                            .colorMultiply(.mainBlack)
                            .frame(width: 28, height: 28)
                    }
                    
                    Spacer()
                    
                    Button {
                        scheduleFormVM.addSchedule()
                        isSchModalVisible = false
                    } label: {
                        Image("confirm")
                            .resizable()
                            .colorMultiply(.mainBlack)
                            .frame(width: 28, height: 28)
                    }
                }
                .padding(.horizontal, 37)
            }
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
                            .toggleStyle(CustomToggleStyle())
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
                                CustomDatePicker(
                                    selection: $scheduleFormVM.repeatStart,
                                    displayedComponents: [.date]
                                )
                                .transition(.picker)
                                
                                if !scheduleFormVM.isAllDay {
                                    CustomDatePicker(
                                        selection: $scheduleFormVM.repeatStart,
                                        displayedComponents: [.hourAndMinute]
                                    )
                                    .transition(.picker)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center) {
                                CustomDatePicker(
                                    selection: $scheduleFormVM.repeatEnd,
                                    displayedComponents: [.date],
                                    pastCutoffDate: scheduleFormVM.repeatStart
                                )
                                .transition(.picker)
                                
                                if !scheduleFormVM.isAllDay {
                                    CustomDatePicker(
                                        selection: $scheduleFormVM.repeatEnd,
                                        displayedComponents: [.hourAndMinute]
                                    )
                                    .transition(.picker)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
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
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("alarm")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .padding(.horizontal, 20)
                        .foregroundColor(scheduleFormVM.isSelectedAlarm ? .mainBlack : .gray2)
                        
                        if scheduleFormVM.isSelectedAlarm {
                            AlarmView(scheduleVM: scheduleFormVM)
                                .padding(.horizontal, 55)
                                .padding(.vertical, 6)
                        }
                        
                        Divider()
                    }
                    
                    // 반복 설정
                    if !scheduleFormVM.overWeek {
                        Group {
                            Label {
                                Toggle(isOn: $scheduleFormVM.isSelectedRepeat.animation(), label: {
                                    HStack {
                                        Text("반복 설정")
                                            .font(.pretendard(size: 14, weight: .medium))
                                        Spacer()
                                    }
                                })
                                .toggleStyle(CustomToggleStyle())
                            } icon: {
                                Image("repeat")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                            .padding(.horizontal, 20)
                            .foregroundColor(scheduleFormVM.isSelectedRepeat ? .mainBlack : .gray2)
                            
                            if scheduleFormVM.isSelectedRepeat {
                                Picker("", selection: $scheduleFormVM.repeatOption.animation()) {
                                    ForEach(getRepeatOption(), id: \.self) {
                                        Text($0.rawValue)
                                            .font(.pretendard(size: 14, weight: .medium))
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal, 55)
                                
                                if scheduleFormVM.repeatOption == .everyYear {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
                                        ForEach(scheduleFormVM.repeatYear.indices, id: \.self) { index in
                                            DayButton(content: scheduleFormVM.repeatYear[index].content, isClicked: scheduleFormVM.repeatYear[index].isClicked) {
                                                scheduleFormVM.toggleDay(repeatOption: .everyYear, index: index)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 55)
                                } else if !scheduleFormVM.overDay, scheduleFormVM.repeatOption == .everyMonth {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20) {
                                        ForEach(scheduleFormVM.repeatMonth.indices, id: \.self) { index in
                                            DayButton(content: scheduleFormVM.repeatMonth[index].content, isClicked: scheduleFormVM.repeatMonth[index].isClicked) {
                                                scheduleFormVM.toggleDay(repeatOption: .everyMonth, index: index)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 55)
                                } else if !scheduleFormVM.overDay, scheduleFormVM.repeatOption == .everySecondWeek ||
                                    scheduleFormVM.repeatOption == .everyWeek
                                {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                        ForEach(scheduleFormVM.repeatWeek.indices, id: \.self) { index in
                                            DayButton(content: scheduleFormVM.repeatWeek[index].content, isClicked: scheduleFormVM.repeatWeek[index].isClicked) {
                                                scheduleFormVM.toggleDay(repeatOption: .everyWeek, index: index)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 55)
                                }
                                
                                Label {
                                    Toggle(isOn: $scheduleFormVM.isSelectedRepeatEnd.animation()) {
                                        HStack {
                                            HStack {
                                                Text("반복 종료일")
                                                    .font(.pretendard(size: 14, weight: .medium))
                                                    .foregroundColor(scheduleFormVM.isSelectedRepeatEnd ? .mainBlack : .gray2)
                                                Spacer()
                                            }
                                            Spacer()
                                            if scheduleFormVM.isSelectedRepeatEnd {
                                                CustomDatePicker(
                                                    selection: $scheduleFormVM.realRepeatEnd,
                                                    displayedComponents: [.date],
                                                    pastCutoffDate: scheduleFormVM.repeatEnd
                                                )
                                                .padding(.vertical, -5)
                                            }
                                        }
                                    }
                                    .toggleStyle(CustomToggleStyle())
                                } icon: {
                                    Image(systemName: "calendar.badge.clock")
                                        .renderingMode(.template)
                                        .frame(width: 28, height: 28)
                                        .hidden()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Divider()
                    }
                    
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
                } // ScrollView
                .padding(.top, 33)
            }
            if scheduleFormVM.mode == .edit {
                Spacer()
                Button {
                    showDeleteActionSheet = true
                    actionSheetOption = scheduleFormVM.tmpIsSelectedRepeatEnd ? .isRepeat : .isNotRepeat
                } label: {
                    HStack {
                        Text("일정 삭제하기")
                            .font(.pretendard(size: 20, weight: .medium))
                        
                        Image("trash")
                            .renderingMode(.template)
                            .frame(width: 28, height: 28)
                    }
                    .foregroundColor(Color(0xF71E58))
                }
                .padding(.bottom, 20)
                .actionSheet(isPresented: $showDeleteActionSheet, content: getDeleteActionSheet)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if scheduleFormVM.mode == .edit {
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
        .toolbar {
            if scheduleFormVM.mode == .edit {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditActionSheet = true
                        actionSheetOption = scheduleFormVM.tmpIsSelectedRepeatEnd ? .isRepeat : .isNotRepeat
                    } label: {
                        Image("confirm")
                            .colorMultiply(.mainBlack)
                            .frame(width: 28, height: 28)
                    }
                    .actionSheet(isPresented: $showEditActionSheet, content: getEditActionSheet)
                }
            }
        }
    }
    
    func getRepeatOption() -> [RepeatOption] {
        let optionCnt = RepeatOption.allCases.count
        return RepeatOption.allCases.suffix(scheduleFormVM.overDay ? optionCnt - 1 : optionCnt)
    }
    
    func getDeleteActionSheet() -> ActionSheet {
        let title = Text(actionSheetOption == .isRepeat ? "이 이벤트를 삭제하시겠습니까? 반복되는 이벤트입니다." : "이 이벤트를 삭제하시겠습니까?")
        let deleteButton: ActionSheet.Button = .destructive(Text("이 이벤트만 삭제")) {
            scheduleFormVM.deleteTargetSchedule()
        }
        let deleteAllButton: ActionSheet.Button = .destructive(Text(actionSheetOption == .isRepeat ? "모든 이벤트 삭제" : "이 이벤트 삭제")) {
            scheduleFormVM.deleteSchedule()
            dismissAction.callAsFunction()
        }
        let cancleButton: ActionSheet.Button = .cancel()
            
        switch actionSheetOption {
        case .isRepeat:
            return ActionSheet(title: title,
                               message: nil,
                               buttons: [deleteButton, deleteAllButton, cancleButton])

        case .isNotRepeat:
            return ActionSheet(title: title,
                               message: nil,
                               buttons: [deleteAllButton, cancleButton])
        }
    }
    
    func getEditActionSheet() -> ActionSheet {
        let title = Text(actionSheetOption == .isRepeat ? "이 이벤트를 편집하시겠습니까? 반복되는 이벤트입니다." : "이 이벤트를 편집하시겠습니까?")
        let editButton: ActionSheet.Button = .destructive(Text("이 이벤트만 편집")) {
            scheduleFormVM.isSelectedRepeat = false
            scheduleFormVM.updateTargetSchedule()
        }
        let editAllButton: ActionSheet.Button = .destructive(Text(actionSheetOption == .isRepeat ? "모든 이벤트 편집" : "이 이벤트 편집")) {
            scheduleFormVM.updateSchedule()
            dismissAction.callAsFunction()
        }
        let cancleButton: ActionSheet.Button = .cancel()

        switch actionSheetOption {
        case .isRepeat:
            if scheduleFormVM.tmpRepeatValue != scheduleFormVM.repeatValue ||
                scheduleFormVM.tmpIsSelectedRepeatEnd != scheduleFormVM.isSelectedRepeat ||
                scheduleFormVM.tmpRealRepeatEnd != scheduleFormVM.realRepeatEnd
            {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [editAllButton, cancleButton])
            } else if scheduleFormVM.tmpRepeatStart.month != scheduleFormVM.repeatStart.month ||
                scheduleFormVM.tmpRepeatStart.day != scheduleFormVM.repeatStart.day ||
                scheduleFormVM.tmpRepeatEnd.month != scheduleFormVM.repeatEnd.month ||
                scheduleFormVM.tmpRepeatEnd.day != scheduleFormVM.repeatEnd.day
            {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [editButton, cancleButton])
            } else {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [editButton, editAllButton, cancleButton])
            }
            
        case .isNotRepeat:
            return ActionSheet(title: title,
                               message: nil,
                               buttons: [editAllButton, cancleButton])
        }
    }
}
