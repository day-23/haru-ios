//
//  TodoAddView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TodoAddView: View {
    init(viewModel: TodoAddViewModel, isModalVisible: Binding<Bool>? = nil) {
        self.viewModel = viewModel
        _isModalVisible = isModalVisible ?? .constant(false)
    }

    @Environment(\.dismiss) var dismissAction
    @ObservedObject var viewModel: TodoAddViewModel
    @Binding var isModalVisible: Bool

    @FocusState private var tagInFocus: Bool
    @FocusState private var memoInFocus: Bool
    @State private var deleteButtonTapped = false
    @State private var updateButtonTapped = false
    @State private var backButtonTapped = false

    @State private var isConfirmButtonActive: Bool = true

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    if self.isModalVisible {
                        HStack(spacing: 0) {
                            Button {
                                withAnimation {
                                    self.isModalVisible = false
                                }
                            } label: {
                                Image("todo-cancel")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0x646464))
                            }

                            Spacer()

                            Button {
                                self.isConfirmButtonActive = false

                                self.viewModel.addTodo { result in
                                    switch result {
                                    case .success:
                                        withAnimation {
                                            self.isModalVisible = false
                                        }
                                    case .failure:
                                        break
                                    }
                                    self.isConfirmButtonActive = true
                                }
                            } label: {
                                Image("confirm")
                                    .renderingMode(.template)
                                    .foregroundColor(self.viewModel.isFieldEmpty ? Color(0xACACAC) : Color(0x646464))
                            }
                            .disabled(self.viewModel.isFieldEmpty || !self.isConfirmButtonActive)
                        }
                        .padding(.horizontal, 33)
                        .padding(.bottom, 27)
                    }

                    // Todo, SubTodo 입력 View
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            TextField("투두 입력", text: self.$viewModel.content)
                                .font(.pretendard(size: 24, weight: .bold))
                                .strikethrough(self.viewModel.todo?.completed ?? false)
                                .foregroundColor(
                                    (self.viewModel.todo?.completed ?? false) ? Color(0xACACAC) : Color(0x191919)
                                )
                                .padding(.leading, 14)

                            StarButton(isClicked: self.viewModel.flag)
                                .onTapGesture {
                                    withAnimation {
                                        self.viewModel.flag.toggle()
                                    }
                                }
                        }
                        .padding(.bottom, 7)

                        ForEach(self.viewModel.subTodoList.indices, id: \.self) { index in
                            HStack {
                                Image("todo-dot")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(0x191919))

                                TextField("", text: self.$viewModel.subTodoList[index].content)
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .strikethrough(self.viewModel.subTodoList[index].completed)
                                    .foregroundColor(
                                        self.viewModel.subTodoList[index].completed ? Color(0xACACAC) : Color(0x191919)
                                    )

                                Button {
                                    self.viewModel.removeSubTodo(index: index)
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundStyle(Color(0x191919))
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .padding(.leading, 14)
                            .padding(.vertical, 7)
                        }

                        if self.viewModel.todo == nil || self.viewModel.todo?.completed == false {
                            Button {
                                self.viewModel.createSubTodo()
                            } label: {
                                Label {
                                    Text("하위 항목 추가")
                                        .font(.pretendard(size: 16, weight: .regular))
                                } icon: {
                                    Image("todo-add-sub-todo")
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
                                        Array(zip(self.viewModel.tagList.indices, self.viewModel.tagList)),
                                        id: \.0
                                    ) { index, tag in
                                        TagView(tag: Tag(id: tag.id, content: tag.content), fontSize: 12)
                                            .onTapGesture {
                                                self.viewModel.tagList.remove(at: index)
                                            }
                                    }

                                    TextField("", text: self.$viewModel.tag)
                                        .placeholder(when: self.viewModel.tag.isEmpty) {
                                            Text("태그 추가")
                                                .font(.pretendard(size: 14, weight: .regular))
                                                .foregroundColor(Color(0xACACAC))
                                        }
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .foregroundColor(self.viewModel.tagList.isEmpty ? Color(0xACACAC) : Color(0x191919))
                                        .onChange(
                                            of: self.viewModel.tag,
                                            perform: self.viewModel.onChangeTag
                                        )
                                        .onSubmit(self.viewModel.onSubmitTag)
                                        .focused(self.$tagInFocus)
                                }
                                .padding(1)
                            }
                            .onTapGesture {
                                self.tagInFocus = true
                            }
                        } icon: {
                            Image(systemName: "tag")
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 10)
                                .foregroundColor(self.viewModel.tagList.isEmpty ? Color(0xACACAC) : Color(0x191919))
                        }
                        .padding(.horizontal, 20)

                        Divider()
                    }

                    // 나의 하루에 추가
                    Group {
                        Label {
                            Toggle(isOn: self.$viewModel.isTodayTodo.animation()) {
                                HStack {
                                    Text("나의 하루에 추가\(self.viewModel.isTodayTodo ? "됨" : "")")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(self.viewModel.isTodayTodo ? Color(0x1DAFFF) : Color(0xACACAC))
                                    Spacer()
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("todo-today-todo")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(self.viewModel.isTodayTodo ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)

                        Divider()
                    }

                    // 알림 설정
                    Group {
                        Label {
                            Toggle(isOn: self.$viewModel.isSelectedAlarm.animation()) {
                                HStack {
                                    Text("알림\(self.viewModel.isSelectedAlarm ? "" : " 설정")")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(self.viewModel.isSelectedAlarm ? Color(0x191919) : Color(0xACACAC))

                                    Spacer()

                                    if self.viewModel.isSelectedAlarm {
                                        CustomDatePicker(selection: self.$viewModel.alarm)
                                    }
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("todo-alarm")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(self.viewModel.isSelectedAlarm ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)

                        Divider()
                    }

                    // 마감 설정
                    Group {
                        Label {
                            Toggle(isOn: self.$viewModel.isSelectedEndDate.animation()) {
                                HStack {
                                    Text(self.viewModel.isSelectedRepeat ? "반복일" : "마감 설정")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(self.viewModel.isSelectedEndDate ? Color(0x191919) : Color(0xACACAC))

                                    Spacer()

                                    if self.viewModel.isSelectedEndDate {
                                        CustomDatePicker(
                                            selection: self.$viewModel.endDate,
                                            displayedComponents: [.date]
                                        )
                                    }
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("todo-end-date")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(self.viewModel.isSelectedEndDate ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)

                        if self.viewModel.isSelectedEndDate {
                            Label {
                                Toggle(isOn: self.$viewModel.isAllDay.animation()) {
                                    HStack {
                                        Text(self.viewModel.isSelectedRepeat ? "시간 설정" : "마감 시간 설정")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .frame(alignment: .leading)
                                            .foregroundColor(self.viewModel.isAllDay ? Color(0x191919) : Color(0xACACAC))

                                        Spacer()

                                        if self.viewModel.isAllDay {
                                            CustomDatePicker(
                                                selection: self.$viewModel.endDate,
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
                            Toggle(isOn: self.$viewModel.isSelectedRepeat.animation()) {
                                HStack {
                                    Text("반복\(self.viewModel.isSelectedRepeat ? "" : " 설정")")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .frame(alignment: .leading)
                                        .foregroundColor(self.viewModel.isSelectedRepeat ? Color(0x191919) : Color(0xACACAC))

                                    Spacer()
                                }
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("todo-repeat")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(self.viewModel.isSelectedRepeat ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)

                        if self.viewModel.isSelectedRepeat {
                            Picker(
                                "",
                                selection: self.$viewModel.repeatOption.animation()
                            ) {
                                ForEach(RepeatOption.allCases, id: \.self) {
                                    Text($0.rawValue)
                                        .font(.pretendard(size: 14, weight: .regular))
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 55)

                            if self.viewModel.repeatOption == .everyYear {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
                                    ForEach(self.viewModel.repeatYear.indices, id: \.self) { index in
                                        DayButton(
                                            content: self.viewModel.repeatYear[index].content,
                                            isClicked: self.viewModel.repeatYear[index].isClicked,
                                            disabled: self.viewModel.buttonDisabledList[index]
                                        ) {
                                            self.viewModel.toggleDay(repeatOption: .everyYear, index: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, 55)
                            } else if self.viewModel.repeatOption == .everyMonth {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20) {
                                    ForEach(self.viewModel.repeatMonth.indices, id: \.self) { index in
                                        DayButton(
                                            content: self.viewModel.repeatMonth[index].content,
                                            isClicked: self.viewModel.repeatMonth[index].isClicked
                                        ) {
                                            self.viewModel.toggleDay(repeatOption: .everyMonth, index: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, 55)
                            } else if self.viewModel.repeatOption == .everySecondWeek ||
                                self.viewModel.repeatOption == .everyWeek
                            {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                    ForEach(self.viewModel.repeatWeek.indices, id: \.self) { index in
                                        DayButton(
                                            content: self.viewModel.repeatWeek[index].content,
                                            isClicked: self.viewModel.repeatWeek[index].isClicked
                                        ) {
                                            self.viewModel.toggleDay(repeatOption: .everyWeek, index: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, 55)
                            }

                            Label {
                                Toggle(isOn: self.$viewModel.isSelectedRepeatEnd.animation()) {
                                    HStack {
                                        Text("반복 종료일")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .frame(alignment: .leading)
                                            .foregroundColor(self.viewModel.isSelectedRepeatEnd ? Color(0x191919) : Color(0xACACAC))
                                        Spacer()
                                        if self.viewModel.isSelectedRepeatEnd {
                                            CustomDatePicker(
                                                selection: self.$viewModel.repeatEnd,
                                                displayedComponents: [.date],
                                                pastCutoffDate: self.viewModel.endDate
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
                                Text("메모\(self.viewModel.memo.isEmpty ? " 추가" : "")")
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .frame(alignment: .leading)
                                    .foregroundColor(!self.viewModel.memo.isEmpty ? Color(0x191919) : Color(0xACACAC))

                                Spacer()
                            }
                            .toggleStyle(CustomToggleStyle())
                        } icon: {
                            Image("todo-memo")
                                .renderingMode(.template)
                                .padding(.trailing, 10)
                                .foregroundColor(!self.viewModel.memo.isEmpty ? Color(0x191919) : Color(0xACACAC))
                        }
                        .padding(.horizontal, 20)

                        TextField("",
                                  text: self.$viewModel.memo,
                                  axis: .vertical)
                            .placeholder(when: self.viewModel.memo.isEmpty) {
                                Text("메모를 작성해주세요.")
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0xACACAC))
                            }
                            .font(.pretendard(size: 14, weight: .regular))
                            .padding(.leading, 45)
                            .padding(.horizontal, 20)
                            .focused(self.$memoInFocus)

                        Divider()
                    }
                }
            }
            .padding(.top, self.isModalVisible ? 0 : 16)
            .navigationBarBackButtonHidden()
            .toolbar {
                if !self.isModalVisible {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if !self.viewModel.isPreviousStateEqual {
                                self.backButtonTapped = true
                            } else {
                                self.dismissAction.callAsFunction()
                            }
                        } label: {
                            Image("back-button")
                                .frame(width: 28, height: 28)
                        }
                        .confirmationDialog(
                            "현재 화면에서 나갈까요? 수정사항이 있습니다.",
                            isPresented: self.$backButtonTapped,
                            titleVisibility: .visible
                        ) {
                            Button("나가기", role: .destructive) {
                                self.dismissAction.callAsFunction()
                            }
                        }
                    }

                    if let complete = viewModel.todo?.completed, !complete {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.updateButtonTapped = true
                            } label: {
                                Image("confirm")
                                    .renderingMode(.template)
                                    .foregroundColor(self.viewModel.isPreviousStateEqual || self.viewModel.isFieldEmpty ? Color(0xACACAC) : Color(0x191919))
                            }
                            .disabled(self.viewModel.isPreviousStateEqual || self.viewModel.isFieldEmpty)
                            .confirmationDialog(
                                self.viewModel.todo?.repeatOption != nil
                                    ? "수정사항을 저장할까요? 반복되는 할 일 입니다."
                                    : "수정사항을 저장할까요?",
                                isPresented: self.$updateButtonTapped,
                                titleVisibility: .visible
                            ) {
                                if self.viewModel.todo?.repeatOption != nil {
                                    // 반복 옵션 미수정, front, middle
                                    if self.viewModel.isPreviousRepeatStateEqual
                                        && self.viewModel.at != .none
                                        && self.viewModel.at != .back
                                    {
                                        Button("이 할 일만 수정") {
                                            // 반복 할 일은 수정시에 반복 관련된 옵션은 null로 만들어 전달해야하기 때문에
                                            // 아래 옵션을 false로 변경한다.
                                            self.viewModel.isSelectedRepeat = false

                                            self.viewModel.updateTodoWithRepeat(
                                                at: self.viewModel.at
                                            ) { result in
                                                switch result {
                                                case .success:
                                                    self.dismissAction.callAsFunction()
                                                case .failure:
                                                    break
                                                }
                                            }
                                        }
                                    }

                                    // middle
                                    if self.viewModel.at == .middle
                                        || self.viewModel.at == .back
                                    {
                                        Button("이 할 일부터 수정") {
                                            self.viewModel.updateTodoWithRepeat(
                                                at: .back
                                            ) { result in
                                                switch result {
                                                case .success:
                                                    self.dismissAction.callAsFunction()
                                                case .failure:
                                                    break
                                                }
                                            }
                                        }
                                    }

                                    if self.viewModel.at == .front {
                                        Button("모든 할 일 수정", role: .destructive) {
                                            self.viewModel.updateTodo { result in
                                                switch result {
                                                case .success:
                                                    self.dismissAction.callAsFunction()
                                                case .failure:
                                                    break
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Button("저장하기") {
                                        self.viewModel.updateTodo { result in
                                            switch result {
                                            case .success:
                                                self.dismissAction.callAsFunction()
                                            case .failure:
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if !self.isModalVisible {
                Button {
                    self.deleteButtonTapped = true
                } label: {
                    HStack(spacing: 10) {
                        Text("할 일 삭제하기")
                            .font(.pretendard(size: 20, weight: .regular))
                        Image("todo-delete")
                            .renderingMode(.template)
                    }
                    .foregroundColor(Color(0xF71E58))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .confirmationDialog(
                    self.viewModel.todo?.repeatOption != nil
                        ? "할 일을 삭제할까요? 반복되는 할 일 입니다."
                        : "할 일을 삭제할까요?",
                    isPresented: self.$deleteButtonTapped,
                    titleVisibility: .visible
                ) {
                    if self.viewModel.todo?.repeatOption != nil {
                        if self.viewModel.at != .none {
                            Button("이 할 일만 삭제", role: .destructive) {
                                self.viewModel.deleteTodoWithRepeat(
                                    at: self.viewModel.at
                                ) { result in
                                    switch result {
                                    case .success:
                                        self.dismissAction.callAsFunction()
                                    case .failure:
                                        break
                                    }
                                }
                            }
                        }

                        // 아래 상황은 뒤에 있는 할 일을 삭제하는 것을 하기보단 repeatEnd를 조정하는 것으로 대신한다.
                        if self.viewModel.at == .middle {
                            Button("이 할 일부터 삭제", role: .destructive) {
                                guard let todo = viewModel.todo else {
                                    print("[Debug] 이 할 일부터 삭제시에, 현재 보고 있는 데이터를 불러오지 못했습니다. \(#fileID), \(#function)")
                                    return
                                }

                                if !self.viewModel.isSelectedRepeatEnd {
                                    self.viewModel.isSelectedRepeatEnd = true
                                }

                                do {
                                    self.viewModel.repeatEnd = try todo.prevEndDate()
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

                                self.viewModel.updateTodo { result in
                                    switch result {
                                    case .success:
                                        self.dismissAction.callAsFunction()
                                    case .failure:
                                        break
                                    }
                                }
                            }
                        }

                        Button("모든 이벤트 삭제", role: .destructive) {
                            self.viewModel.deleteTodo { result in
                                switch result {
                                case .success:
                                    self.dismissAction.callAsFunction()
                                case .failure:
                                    break
                                }
                            }
                        }
                    } else {
                        Button("삭제하기", role: .destructive) {
                            self.viewModel.deleteTodo { result in
                                switch result {
                                case .success:
                                    self.dismissAction.callAsFunction()
                                case .failure:
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: self.tagInFocus, perform: { value in
            if !value {
                self.viewModel.onSubmitTag()
            }
        })
        .onDisappear {
            self.viewModel.clear()
        }
    }
}
