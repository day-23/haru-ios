//
//  TodoAddView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TodoAddView: View {
    @Environment(\.dismiss) var dismissAction
    @ObservedObject var viewModel: TodoAddViewModel
    @Binding var isModalVisible: Bool
    @FocusState private var tagInFocus: Bool
    @FocusState private var memoInFocus: Bool
    @State private var deleteButtonTapped = false
    @State private var updateButtonTapped = false
    @State private var backButtonTapped = false
    
    @State private var isConfirmButtonActive: Bool = true

    init(viewModel: TodoAddViewModel, isModalVisible: Binding<Bool>? = nil) {
        self.viewModel = viewModel
        _isModalVisible = isModalVisible ?? .constant(false)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    if isModalVisible {
                        HStack(spacing: 0) {
                            Button {
                                withAnimation {
                                    isModalVisible = false
                                }
                            } label: {
                                Image("cancel")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0x191919))
                            }
                            
                            Spacer()
                            
                            Button {
                                isConfirmButtonActive = false
                                
                                viewModel.addTodo { result in
                                    switch result {
                                    case .success:
                                        withAnimation {
                                            isModalVisible = false
                                        }
                                    case let .failure(failure):
                                        print("[Debug] \(failure) \(#fileID) \(#function)")
                                    }
                                    isConfirmButtonActive = true
                                }
                            } label: {
                                Image("confirm")
                                    .renderingMode(.template)
                                    .foregroundColor(viewModel.isFieldEmpty ? Color(0xACACAC) : Color(0x191919))
                            }
                            .disabled(viewModel.isFieldEmpty || !isConfirmButtonActive)
                        }
                        .padding(.horizontal, 33)
                        .padding(.bottom, 27)
                    }
                    
                    // Todo, SubTodo 입력 View
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            TextField("투두 입력", text: $viewModel.content)
                                .font(.pretendard(size: 24, weight: .bold))
                                .strikethrough(viewModel.todo?.completed ?? false)
                                .foregroundColor(
                                    (viewModel.todo?.completed ?? false) ? Color(0xACACAC) : Color(0x191919)
                                )
                                .padding(.leading, 14)
                            
                            StarButton(isClicked: viewModel.flag)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.flag.toggle()
                                    }
                                }
                        }
                        .padding(.bottom, 7)
                        
                        ForEach(viewModel.subTodoList.indices, id: \.self) { index in
                            HStack {
                                Image("dot")
                                TextField("", text: $viewModel.subTodoList[index].content)
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .strikethrough(viewModel.subTodoList[index].completed)
                                    .foregroundColor(
                                        viewModel.subTodoList[index].completed ? Color(0xACACAC) : Color(0x191919)
                                    )
                                
                                Button {
                                    viewModel.removeSubTodo(index: index)
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundStyle(Color(0x191919))
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .padding(.leading, 14)
                            .padding(.vertical, 7)
                        }
                        
                        if viewModel.todo == nil || viewModel.todo?.completed == false {
                            Button {
                                viewModel.createSubTodo()
                            } label: {
                                Label {
                                    Text("하위 항목 추가")
                                        .font(.pretendard(size: 16, weight: .regular))
                                } icon: {
                                    Image("add-sub-todo")
                                        .renderingMode(.template)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(0xACACAC))
                                }
                            }
                            .padding(.leading, 14)
                            .padding(.vertical, 7)
                            .foregroundColor(Color(0xACACAC))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                    
                    // Tag 입력 View
                    Group {
                        Label {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(
                                        Array(zip(viewModel.tagList.indices, viewModel.tagList)),
                                        id: \.0
                                    ) { index, tag in
                                        TagView(tag: Tag(id: tag.id, content: tag.content), fontSize: 12)
                                            .onTapGesture {
                                                viewModel.tagList.remove(at: index)
                                            }
                                    }
                                    
                                    TextField("", text: $viewModel.tag)
                                        .placeholder(when: viewModel.tag.isEmpty) {
                                            Text("태그 추가")
                                                .font(.pretendard(size: 14, weight: .regular))
                                                .foregroundColor(Color(0xACACAC))
                                        }
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .foregroundColor(viewModel.tagList.isEmpty ? Color(0xACACAC) : Color(0x191919))
                                        .onChange(
                                            of: viewModel.tag,
                                            perform: viewModel.onChangeTag
                                        )
                                        .onSubmit(viewModel.onSubmitTag)
                                        .focused($tagInFocus)
                                }
                                .padding(1)
                            }
                            .onTapGesture {
                                tagInFocus = true
                            }
                        } icon: {
                            Image(systemName: "tag")
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel.tagList.isEmpty ? Color(0xACACAC) : Color(0x191919))
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                    }
                    
                    // 나의 하루에 추가
                    Group {
                        Label {
                            Toggle(isOn: $viewModel.isTodayTodo.animation()) {
                                HStack {
                                    Text("나의 하루에 추가\(viewModel.isTodayTodo ? "됨" : "")")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel.isTodayTodo ? Color(0x1DAFFF) : Color(0xACACAC))
                                    Spacer()
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("today-todo")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel.isTodayTodo ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                    }
                    
                    // 알림 설정
                    Group {
                        Label {
                            Toggle(isOn: $viewModel.isSelectedAlarm.animation()) {
                                HStack {
                                    Text("알림\(viewModel.isSelectedAlarm ? "" : " 설정")")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel.isSelectedAlarm ? Color(0x191919) : Color(0xACACAC))
                                    
                                    Spacer()
                                    
                                    if viewModel.isSelectedAlarm {
                                        CustomDatePicker(selection: $viewModel.alarm)
                                    }
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("alarm")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel.isSelectedAlarm ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                    }
                    
                    // 마감 설정
                    Group {
                        Label {
                            Toggle(isOn: $viewModel.isSelectedEndDate.animation()) {
                                HStack {
                                    Text(viewModel.isSelectedRepeat ? "반복일" : "마감 설정")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel.isSelectedEndDate ? Color(0x191919) : Color(0xACACAC))
                                    
                                    Spacer()
                                    
                                    if viewModel.isSelectedEndDate {
                                        CustomDatePicker(
                                            selection: $viewModel.endDate,
                                            displayedComponents: [.date]
                                        )
                                    }
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("date")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel.isSelectedEndDate ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.isSelectedEndDate {
                            Label {
                                Toggle(isOn: $viewModel.isAllDay.animation()) {
                                    HStack {
                                        Text(viewModel.isSelectedRepeat ? "시간 설정" : "마감 시간 설정")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .frame(alignment: .leading)
                                            .foregroundColor(viewModel.isAllDay ? Color(0x191919) : Color(0xACACAC))
                                        
                                        Spacer()
                                        
                                        if viewModel.isAllDay {
                                            CustomDatePicker(
                                                selection: $viewModel.endDate,
                                                displayedComponents: [.hourAndMinute]
                                            )
                                        }
                                    }
                                }
                                .toggleStyle(CustomToggleStyle())
                            } icon: {
                                Image(systemName: "clock")
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 10)
                                    .hidden()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Divider()
                    }
                    
                    // 반복 설정
                    Group {
                        Label {
                            Toggle(isOn: $viewModel.isSelectedRepeat.animation()) {
                                HStack {
                                    Text("반복\(viewModel.isSelectedRepeat ? "" : " 설정")")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel.isSelectedRepeat ? Color(0x191919) : Color(0xACACAC))
                                    
                                    Spacer()
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("repeat")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel.isSelectedRepeat ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.isSelectedRepeat {
                            Picker(
                                "",
                                selection: $viewModel.repeatOption.animation()
                            ) {
                                ForEach(RepeatOption.allCases, id: \.self) {
                                    Text($0.rawValue)
                                        .font(.pretendard(size: 14, weight: .regular))
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 55)
                            
                            if viewModel.repeatOption == .everyYear {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
                                    ForEach(viewModel.repeatYear.indices, id: \.self) { index in
                                        DayButton(
                                            content: viewModel.repeatYear[index].content,
                                            isClicked: viewModel.repeatYear[index].isClicked,
                                            disabled: viewModel.buttonDisabledList[index]
                                        ) {
                                            viewModel.toggleDay(repeatOption: .everyYear, index: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, 55)
                            } else if viewModel.repeatOption == .everyMonth {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20) {
                                    ForEach(viewModel.repeatMonth.indices, id: \.self) { index in
                                        DayButton(
                                            content: viewModel.repeatMonth[index].content,
                                            isClicked: viewModel.repeatMonth[index].isClicked
                                        ) {
                                            viewModel.toggleDay(repeatOption: .everyMonth, index: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, 55)
                            } else if viewModel.repeatOption == .everySecondWeek ||
                                viewModel.repeatOption == .everyWeek
                            {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                    ForEach(viewModel.repeatWeek.indices, id: \.self) { index in
                                        DayButton(
                                            content: viewModel.repeatWeek[index].content,
                                            isClicked: viewModel.repeatWeek[index].isClicked
                                        ) {
                                            viewModel.toggleDay(repeatOption: .everyWeek, index: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, 55)
                            }
                            
                            Label {
                                Toggle(isOn: $viewModel.isSelectedRepeatEnd.animation()) {
                                    HStack {
                                        Text("반복 종료일")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .frame(alignment: .leading)
                                            .foregroundColor(viewModel.isSelectedRepeatEnd ? Color(0x191919) : Color(0xACACAC))
                                        Spacer()
                                        if viewModel.isSelectedRepeatEnd {
                                            CustomDatePicker(
                                                selection: $viewModel.repeatEnd,
                                                displayedComponents: [.date],
                                                pastCutoffDate: viewModel.endDate
                                            )
                                        }
                                    }
                                }
                                .toggleStyle(CustomToggleStyle())
                            } icon: {
                                Image(systemName: "calendar.badge.clock")
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 10)
                                    .hidden()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Divider()
                    }
                    
                    // 메모 추가
                    Group {
                        Label {
                            HStack {
                                Text("메모\(viewModel.memo.isEmpty ? " 추가" : "")")
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .frame(alignment: .leading)
                                    .foregroundColor(!viewModel.memo.isEmpty ? Color(0x191919) : Color(0xACACAC))
                                
                                Spacer()
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("memo")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(!viewModel.memo.isEmpty ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)
                        
                        TextField("",
                                  text: $viewModel.memo,
                                  axis: .vertical)
                            .placeholder(when: viewModel.memo.isEmpty) {
                                Text("메모를 작성해주세요.")
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0xACACAC))
                            }
                            .font(.pretendard(size: 14, weight: .regular))
                            .padding(.leading, 45)
                            .padding(.horizontal, 20)
                            .focused($memoInFocus)
                        
                        Divider()
                    }
                }
            }
            .padding(.top, isModalVisible ? 0 : 16)
            .navigationBarBackButtonHidden()
            .toolbar {
                if !isModalVisible {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if !viewModel.isPreviousStateEqual {
                                backButtonTapped = true
                            } else {
                                dismissAction.callAsFunction()
                            }
                        } label: {
                            Image("back-button")
                                .frame(width: 28, height: 28)
                        }
                        .confirmationDialog(
                            "현재 화면에서 나갈까요? 수정사항이 있습니다.",
                            isPresented: $backButtonTapped,
                            titleVisibility: .visible
                        ) {
                            Button("나가기", role: .destructive) {
                                dismissAction.callAsFunction()
                            }
                        }
                    }
                    
                    if let complete = viewModel.todo?.completed, !complete {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                updateButtonTapped = true
                            } label: {
                                Image("confirm")
                                    .renderingMode(.template)
                                    .foregroundColor(viewModel.isPreviousStateEqual || viewModel.isFieldEmpty ? Color(0xACACAC) : Color(0x191919))
                            }
                            .disabled(viewModel.isPreviousStateEqual || viewModel.isFieldEmpty)
                            .confirmationDialog(
                                viewModel.todo?.repeatOption != nil
                                    ? "수정사항을 저장할까요? 반복되는 할 일 입니다."
                                    : "수정사항을 저장할까요?",
                                isPresented: $updateButtonTapped,
                                titleVisibility: .visible
                            ) {
                                if viewModel.todo?.repeatOption != nil {
                                    if viewModel.isPreviousRepeatStateEqual
                                        && viewModel.at != .none
                                    {
                                        Button("이 할 일만 수정") {
                                            // 반복 할 일은 수정시에 반복 관련된 옵션은 null로 만들어 전달해야하기 때문에
                                            // 아래 옵션을 false로 변경한다.
                                            viewModel.isSelectedRepeat = false
                                            
                                            viewModel.updateTodoWithRepeat(
                                                at: viewModel.at
                                            ) { result in
                                                switch result {
                                                case .success:
                                                    dismissAction.callAsFunction()
                                                case let .failure(failure):
                                                    print("[Debug] \(failure) \(#fileID) \(#function)")
                                                }
                                            }
                                        }
                                    }
                                    
                                    if (viewModel.isPreviousEndDateEqual
                                        || (!viewModel.isPreviousEndDateEqual
                                            && !viewModel.isPreviousRepeatStateEqual))
                                        && viewModel.at != .front
                                        && viewModel.at != .none
                                    {
                                        Button("이 할 일부터 수정") {
                                            viewModel.updateTodoWithRepeat(
                                                at: .back
                                            ) { result in
                                                switch result {
                                                case .success:
                                                    dismissAction.callAsFunction()
                                                case let .failure(failure):
                                                    print("[Debug] \(failure) \(#fileID) \(#function)")
                                                }
                                            }
                                        }
                                    }
                                    
                                    if viewModel.isPreviousEndDateEqual
                                        || (!viewModel.isPreviousEndDateEqual
                                            && !viewModel.isPreviousRepeatStateEqual)
                                    {
                                        Button("모든 할 일 수정", role: .destructive) {
                                            viewModel.updateTodo { result in
                                                switch result {
                                                case .success:
                                                    dismissAction.callAsFunction()
                                                case let .failure(failure):
                                                    print("[Debug] \(failure) \(#fileID) \(#function)")
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Button("저장하기") {
                                        viewModel.updateTodo { result in
                                            switch result {
                                            case .success:
                                                dismissAction.callAsFunction()
                                            case let .failure(failure):
                                                print("[Debug] \(failure) \(#fileID) \(#function)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if !isModalVisible {
                Button {
                    deleteButtonTapped = true
                } label: {
                    HStack(spacing: 10) {
                        Text("할 일 삭제하기")
                            .font(.pretendard(size: 20, weight: .regular))
                        Image("trash")
                            .renderingMode(.template)
                    }
                    .foregroundColor(Color(0xF71E58))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .confirmationDialog(
                    viewModel.todo?.repeatOption != nil
                        ? "할 일을 삭제할까요? 반복되는 할 일 입니다."
                        : "할 일을 삭제할까요?",
                    isPresented: $deleteButtonTapped,
                    titleVisibility: .visible
                ) {
                    if viewModel.todo?.repeatOption != nil {
                        if viewModel.at != .none {
                            Button("이 할 일만 삭제", role: .destructive) {
                                viewModel.deleteTodoWithRepeat(
                                    at: viewModel.at
                                ) { result in
                                    switch result {
                                    case .success:
                                        dismissAction.callAsFunction()
                                    case let .failure(failure):
                                        print("[Debug] \(failure) \(#fileID) \(#function)")
                                    }
                                }
                            }
                        }
                        
                        // 아래 상황은 뒤에 있는 할 일을 삭제하는 것을 하기보단 repeatEnd를 조정하는 것으로 대신한다.
                        if viewModel.at == .middle {
                            Button("이 할 일부터 삭제", role: .destructive) {
                                guard let todo = viewModel.todo else {
                                    print("[Debug] 이 할 일부터 삭제시에, 현재 보고 있는 데이터를 불러오지 못했습니다. \(#fileID), \(#function)")
                                    return
                                }
                                
                                if !viewModel.isSelectedRepeatEnd {
                                    viewModel.isSelectedRepeatEnd = true
                                }
                                
                                do {
                                    viewModel.repeatEnd = try todo.prevEndDate()
                                } catch {
                                    switch error {
                                    case RepeatError.invalid:
                                        print("[Debug] 입력 데이터에 문제가 있습니다. \(#fileID) \(#function)")
                                    case RepeatError.calculation:
                                        print("[Debug] 날짜를 계산하는데 있어 오류가 있습니다. \(#fileID) \(#function)")
                                    default:
                                        print("[Debug] 알 수 없는 오류입니다. \(#fileID) \(#function)")
                                    }
                                }
                                
                                viewModel.updateTodo { result in
                                    switch result {
                                    case .success:
                                        dismissAction.callAsFunction()
                                    case let .failure(failure):
                                        print("[Debug] \(failure) \(#fileID) \(#function)")
                                    }
                                }
                            }
                        }
                        
                        Button("모든 이벤트 삭제", role: .destructive) {
                            viewModel.deleteTodo { result in
                                switch result {
                                case .success:
                                    dismissAction.callAsFunction()
                                case let .failure(failure):
                                    print("[Debug] \(failure) \(#fileID) \(#function)")
                                }
                            }
                        }
                    } else {
                        Button("삭제하기", role: .destructive) {
                            viewModel.deleteTodo { result in
                                switch result {
                                case .success:
                                    dismissAction.callAsFunction()
                                case let .failure(failure):
                                    print("[Debug] \(failure) \(#fileID) \(#function)")
                                }
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            viewModel.clear()
        }
    }
}
