//
//  ScheduleFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import PopupView
import SwiftUI

struct ScheduleFormView: View, KeyboardReadable {
    @Environment(\.dismiss) var dismissAction
    @StateObject var scheduleFormVM: ScheduleFormViewModel

    @Binding var isSchModalVisible: Bool // 일정 추가하는 경우 true

    @State private var showCategorySheet: Bool = false
    @State private var showingPopup: Bool = false
    @State private var backButtonToggle: Bool = false

    @State private var selectedIdx: Int?
    
    @State var showDeleteActionSheet: Bool = false
    @State var showEditActionSheet: Bool = false
    @State var actionSheetOption: ActionSheetOption = .isNotRepeat
    
    @State private var keyboardUp: Bool = false
        
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
                        Image("todo-cancel")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(isClear() ? Color(0xacacac) : Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                    
                    Spacer()
                    
                    Button {
                        scheduleFormVM.addSchedule()
                        isSchModalVisible = false
                    } label: {
                        Image("confirm")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(scheduleFormVM.buttonDisable ? Color(0xacacac) : Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                    .disabled(scheduleFormVM.buttonDisable)
                }
                .padding(.leading, 37)
                .padding(.trailing, 30)
            } else if scheduleFormVM.mode == .edit {
                HStack {
                    Button {
                        backButtonToggle = true
                            
                    } label: {
                        Image("back-button")
                            .frame(width: 28, height: 28)
                    }
                    .confirmationDialog(
                        "현재 화면에서 나갈까요? 수정 사항은 저장되지 않습니다.",
                        isPresented: $backButtonToggle,
                        titleVisibility: .visible
                    ) {
                        Button("나가기", role: .destructive) {
                            dismissAction.callAsFunction()
                        }
                    }
                    
                    Spacer()
                    
                    if scheduleFormVM.overWeek {
                        Button {
                            showEditActionSheet = true
                            actionSheetOption = scheduleFormVM.tmpRepeatOption != nil ? .isRepeat : .isNotRepeat
                        } label: {
                            Image("confirm")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(scheduleFormVM.buttonDisable ? Color(0xacacac) : Color(0x191919))
                                .frame(width: 28, height: 28)
                        }
                        .confirmationDialog(
                            "수정사항을 저장할까요?",
                            isPresented: $showEditActionSheet,
                            titleVisibility: .visible
                        ) {
                            Button("저장하기", role: .destructive) {
                                scheduleFormVM.updateSchedule()
                                dismissAction.callAsFunction()
                            }
                        }
                    } else {
                        Button {
                            showEditActionSheet = true
                            actionSheetOption = scheduleFormVM.tmpRepeatOption != nil ? .isRepeat : .isNotRepeat
                        } label: {
                            Image("confirm")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(scheduleFormVM.buttonDisable ? Color(0xacacac) : Color(0x191919))
                                .frame(width: 28, height: 28)
                        }
                        .actionSheet(isPresented: $showEditActionSheet, content: getEditActionSheet)
                        .disabled(scheduleFormVM.buttonDisable)
                    }
                }
                .padding(.horizontal, 20)
                .overlay {
                    Text("일정 수정")
                        .font(.pretendard(size: 20, weight: .bold))
                        .foregroundColor(Color(0x191919))
                }
                .padding(.top, 5)
                .padding(.bottom, 19)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    // 일정 입력
                    Group {
                        HStack(spacing: 0) {
                            TextField("", text: $scheduleFormVM.content)
                                .placeholder(when: scheduleFormVM.content.isEmpty, placeholder: {
                                    Text("일정을 입력하세요")
                                        .font(.pretendard(size: 24, weight: .regular))
                                        .foregroundColor(Color(0xacacac))
                                })
                                .font(Font.system(size: 24, weight: .bold))
                                .foregroundColor(Color(0x191919))
                                .onChange(of: scheduleFormVM.content) { value in
                                    if value.count > 50 {
                                        scheduleFormVM.content = String(
                                            value[
                                                value.startIndex ..< value.index(value.endIndex, offsetBy: -1)
                                            ]
                                        )
                                    }
                                }
                                
                            Group {
                                if let selectIndex = scheduleFormVM.selectionCategory {
                                    Button {
                                        showCategorySheet = true
                                    } label: {
                                        Circle()
                                            .fill(Color(scheduleFormVM.categoryList[selectIndex].color))
                                            .frame(width: 28, height: 28)
                                    }
                                    .popup(isPresented: $showCategorySheet) {
                                        CategoryView(
                                            scheduleFormVM: scheduleFormVM,
                                            selectedIdx: $selectedIdx,
                                            showCategorySheet: $showCategorySheet
                                        )
                                        .onAppear {
                                            selectedIdx = scheduleFormVM.selectionCategory
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
                                    Button {
                                        showCategorySheet = true
                                    } label: {
                                        Circle()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.gray2)
                                    }
                                    .popup(isPresented: $showCategorySheet) {
                                        CategoryView(
                                            scheduleFormVM: scheduleFormVM,
                                            selectedIdx: $selectedIdx,
                                            showCategorySheet: $showCategorySheet
                                        )
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
                            }
                            .padding(.trailing, !isSchModalVisible ? -10 : 0)
                        }
                        .padding(.leading, 34)
                        .padding(.trailing, scheduleFormVM.mode == .edit ? 34 : 24)
                        
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
                            Image("calendar-all-day")
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
                                    pastCutoffDate: scheduleFormVM.repeatStart,
                                    isWarning: $scheduleFormVM.isWarning
                                )
                                .transition(.picker)
                                
                                if !scheduleFormVM.isAllDay {
                                    CustomDatePicker(
                                        selection: $scheduleFormVM.repeatEnd,
                                        displayedComponents: [.hourAndMinute],
                                        isWarning: $scheduleFormVM.isWarning
                                    )
                                    .transition(.picker)
                                }
                            }
                        }
                        .padding(.horizontal, 50)
                        
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
                            Image("todo-alarm")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .padding(.horizontal, 20)
                        .foregroundColor(scheduleFormVM.isSelectedAlarm ? .mainBlack : .gray2)
                        
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
                                Image("todo-repeat")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                            .padding(.horizontal, 20)
                            .foregroundColor(scheduleFormVM.isSelectedRepeat ? .mainBlack : .gray2)
                            
                            if scheduleFormVM.isSelectedRepeat {
                                Picker(
                                    "",
                                    selection: $scheduleFormVM.repeatOption.animation()
                                ) {
                                    ForEach(getRepeatOption(), id: \.self) {
                                        if scheduleFormVM.overMonth,
                                           $0.rawValue == "매달" ||
                                           $0.rawValue == "매년"
                                        {
                                            Text($0.rawValue)
                                                .font(.pretendard(size: 14, weight: .bold))
                                        } else {
                                            Text($0.rawValue)
                                                .font(.pretendard(size: 14, weight: .medium))
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal, 55)
                                
                                if !scheduleFormVM.overDay, scheduleFormVM.repeatOption == .everyYear {
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
                            Image("todo-memo")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .padding(.horizontal, 20)
                        .foregroundColor(scheduleFormVM.memo.isEmpty ? .gray2 : .mainBlack)
                        
                        TextField("", text: $scheduleFormVM.memo, axis: .vertical)
                            .placeholder(when: self.scheduleFormVM.memo.isEmpty) {
                                Text("메모를 작성해주세요.")
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0xacacac))
                            }
                            .font(.pretendard(size: 14, weight: .regular))
                            .padding(.leading, 37)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .onChange(of: scheduleFormVM.memo) { _ in
                                if scheduleFormVM.memo.count > 500 {
                                    let memo = scheduleFormVM.memo
                                    scheduleFormVM.memo = String(memo[memo.startIndex ..< memo.index(memo.endIndex, offsetBy: -1)])
                                }
                            }
                        
                        Divider()
                    }
                } // ScrollView
                .padding(.top, 33)
            }
            .padding(.top, scheduleFormVM.mode == .edit ? -10 : 0)
            if scheduleFormVM.mode == .edit,
               !keyboardUp
            {
                Spacer()
                if scheduleFormVM.overWeek {
                    Button {
                        showDeleteActionSheet = true
                        actionSheetOption = scheduleFormVM.tmpRepeatOption != nil ? .isRepeat : .isNotRepeat
                    } label: {
                        HStack {
                            Text("일정 삭제")
                                .font(.pretendard(size: 20, weight: .medium))
                            
                            Image("todo-delete")
                                .renderingMode(.template)
                                .frame(width: 28, height: 28)
                        }
                        .foregroundColor(Color(0xf71e58))
                    }
                    .padding(.bottom, 20)
                    .confirmationDialog(
                        "이 일정을 삭제할까요?",
                        isPresented: $showDeleteActionSheet,
                        titleVisibility: .visible
                    ) {
                        Button("삭제하기", role: .destructive) {
                            scheduleFormVM.deleteSchedule()
                            dismissAction.callAsFunction()
                        }
                    }
                } else {
                    Button {
                        showDeleteActionSheet = true
                        actionSheetOption = scheduleFormVM.tmpRepeatOption != nil ? .isRepeat : .isNotRepeat
                    } label: {
                        HStack {
                            Text("일정 삭제")
                                .font(.pretendard(size: 20, weight: .medium))
                            
                            Image("todo-delete")
                                .renderingMode(.template)
                                .frame(width: 28, height: 28)
                        }
                        .foregroundColor(Color(0xf71e58))
                    }
                    .padding(.bottom, 20)
                    .actionSheet(isPresented: $showDeleteActionSheet, content: getDeleteActionSheet)
                }
            }
        }
        .onReceive(keyboardEventPublisher, perform: { value in
            withAnimation {
                keyboardUp = value
            }
        })
        .navigationBarBackButtonHidden()
    }
    
    func isClear() -> Bool {
        scheduleFormVM.content == "" &&
            scheduleFormVM.selectionCategory == nil &&
            scheduleFormVM.isSelectedAlarm == false &&
            scheduleFormVM.isSelectedRepeat == false &&
            scheduleFormVM.memo == ""
    }
    
    func getRepeatOption() -> [RepeatOption] {
        // 조건에 따라 필터링
        if scheduleFormVM.overMonth {
            return RepeatOption.allCases.filter { option in
                option != .everyDay && option != .everyMonth
            }
        } else if scheduleFormVM.overDay {
            return RepeatOption.allCases.filter { option in
                option != .everyDay
            }
        } else {
            return RepeatOption.allCases
        }
    }
    
    func getDeleteActionSheet() -> ActionSheet {
        let title = Text(actionSheetOption == .isRepeat ? "이 일정을 삭제할까요? 반복되는 일정입니다." : "이 일정을 삭제할까요?")
        
        let deleteButton: ActionSheet.Button = .destructive(Text("이 일정만 삭제")) {
            scheduleFormVM.deleteTargetSchedule()
            dismissAction.callAsFunction()
        }
        
        let deleteAfterButton: ActionSheet.Button = .destructive(Text("이 일정부터 삭제")) {
            scheduleFormVM.deleteTargetSchedule(isAfter: true)
            dismissAction.callAsFunction()
        }
        
        let deleteAllButton: ActionSheet.Button = .destructive(
            Text(actionSheetOption == .isRepeat ? "모든 이벤트 삭제" : "삭제하기")
        ) {
            scheduleFormVM.deleteSchedule()
            dismissAction.callAsFunction()
        }
        
        let cancleButton: ActionSheet.Button = .cancel()
            
        switch actionSheetOption {
        case .isRepeat:
            if (scheduleFormVM.from == .calendar && scheduleFormVM.oriSchedule?.at == RepeatAt.none)
                || (scheduleFormVM.from == .timeTable && scheduleFormVM.at == .none)
            {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [deleteAllButton, cancleButton])
            } else if (scheduleFormVM.from == .calendar && scheduleFormVM.oriSchedule?.at == .front)
                || (scheduleFormVM.from == .timeTable && scheduleFormVM.at == .front)
            {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [deleteButton, deleteAllButton, cancleButton])
            } else if (scheduleFormVM.from == .calendar && scheduleFormVM.oriSchedule?.at == .middle)
                || (scheduleFormVM.from == .timeTable && scheduleFormVM.at == .middle)
            {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [deleteButton, deleteAfterButton, deleteAllButton, cancleButton])
            } else {
                return ActionSheet(title: title,
                                   message: nil,
                                   buttons: [deleteButton, deleteAllButton, cancleButton])
            }

        case .isNotRepeat:
            return ActionSheet(title: title,
                               message: nil,
                               buttons: [deleteAllButton, cancleButton])
        }
    }
    
    func getEditActionSheet() -> ActionSheet {
        let title = Text(actionSheetOption == .isRepeat ? "수정사항을 저장할까요? 반복되는 일정입니다." : "수정사항을 저장할까요?")
        
        let editButton: ActionSheet.Button = .default(Text("이 일정만 수정")) {
            scheduleFormVM.isSelectedRepeat = false
            scheduleFormVM.updateTargetSchedule()
        }
        
        let editAfterButton: ActionSheet.Button = .destructive(Text("이 일정부터 수정")) {
            scheduleFormVM.updateTargetSchedule(isAfter: true)
        }
        
        let editAllButton: ActionSheet.Button = .destructive(
            Text(actionSheetOption == .isRepeat ? "반복 일정 모두 수정" : "저장하기")
        ) {
            scheduleFormVM.updateSchedule()
            dismissAction.callAsFunction()
        }
        
        let cancleButton: ActionSheet.Button = .cancel()

        switch actionSheetOption {
        case .isRepeat:
            // 반복 종료일 건드리는 경우
            if scheduleFormVM.tmpIsSelectedRepeatEnd != scheduleFormVM.isSelectedRepeatEnd ||
                (scheduleFormVM.tmpIsSelectedRepeatEnd &&
                    scheduleFormVM.tmpRealRepeatEnd != scheduleFormVM.realRepeatEnd)
            {
                if (scheduleFormVM.from == .calendar
                    && (scheduleFormVM.oriSchedule?.at == .front || scheduleFormVM.oriSchedule?.at == RepeatAt.none))
                    || (scheduleFormVM.from == .timeTable
                        && (scheduleFormVM.at == .front || scheduleFormVM.at == .none))
                {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editAllButton, cancleButton])
                } else {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editAfterButton, cancleButton])
                }
            }
            // 반복 옵션 건드리는 경우
            else if scheduleFormVM.tmpRepeatOption != scheduleFormVM.repeatOption ||
                scheduleFormVM.tmpRepeatValue != scheduleFormVM.repeatValue
            {
                if (scheduleFormVM.from == .calendar
                    && (scheduleFormVM.oriSchedule?.at == .front || scheduleFormVM.oriSchedule?.at == RepeatAt.none))
                    || (scheduleFormVM.from == .timeTable
                        && (scheduleFormVM.at == .front || scheduleFormVM.at == .none))
                {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editAllButton, cancleButton])
                } else {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editAfterButton, cancleButton])
                }
            } else {
                if (scheduleFormVM.from == .calendar && scheduleFormVM.oriSchedule?.at == .front)
                    || (scheduleFormVM.from == .timeTable && scheduleFormVM.at == .front)
                {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editButton, editAllButton, cancleButton])
                } else if (scheduleFormVM.from == .calendar && scheduleFormVM.oriSchedule?.at == RepeatAt.none)
                    || (scheduleFormVM.from == .timeTable && scheduleFormVM.at == .none)
                {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editAllButton, cancleButton])
                } else {
                    return ActionSheet(title: title,
                                       message: nil,
                                       buttons: [editButton, editAfterButton, cancleButton])
                }
            }
            
        case .isNotRepeat:
            return ActionSheet(title: title,
                               message: nil,
                               buttons: [editAllButton, cancleButton])
        }
    }
}
