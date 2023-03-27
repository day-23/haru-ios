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
    @State private var isClicked = false

    init(viewModel: TodoAddViewModel, isModalVisible: Binding<Bool>? = nil) {
        self.viewModel = viewModel
        _isModalVisible = isModalVisible ?? .constant(false)
    }

    var body: some View {
        ScrollView {
            VStack {
                if viewModel.mode == .add {
                    HStack(spacing: 0) {
                        Button {
                            withAnimation {
                                isModalVisible = false
                            }
                        } label: {
                            Image("cancel")
                        }
                        Spacer()
                        Button {
                            viewModel.addTodo { result in
                                switch result {
                                case .success:
                                    withAnimation {
                                        isModalVisible = false
                                    }
                                case let .failure(failure):
                                    print("[Debug] \(failure) (\(#fileID), \(#function))")
                                }
                            }
                        } label: {
                            Image("confirm")
                        }
                    }
                    .padding(.horizontal, 33)
                    .padding(.bottom, 27)
                }

                //  Todo, SubTodo 입력 View
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        if !isModalVisible {
                            //  FIXME: 완료 API 호출해야 함.
                            CompleteButton(isClicked: isClicked)
                                .onTapGesture {
                                    withAnimation {
                                        isClicked.toggle()
                                    }
                                }
                        }

                        TextField("투두 입력", text: $viewModel.todoContent)
                            .padding(.leading, isModalVisible ? 14 : 12)
                            .font(.pretendard(size: 24, weight: .medium))

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
                                .font(.system(size: 14, weight: .light))
                            Button {
                                viewModel.removeSubTodo(index: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(Color(0xACACAC))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)

                        Divider()
                    }

                    Button {
                        viewModel.createSubTodo()
                    } label: {
                        Label {
                            Text("하위 항목 추가")
                                .font(.system(size: 14, weight: .medium))
                        } icon: {
                            Image("add-sub-todo")
                                .frame(width: 28, height: 28)
                        }
                    }
                    .padding(.leading, 14)
                    .padding(.vertical, 7)
                    .foregroundColor(Color(0xACACAC))

                    Divider()
                }
                .padding(.horizontal, 20)

                //  Tag 입력 View
                Group {
                    Label {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(
                                    Array(zip(viewModel.tagList.indices, viewModel.tagList)),
                                    id: \.0
                                ) { index, tag in
                                    TagView(tag: Tag(id: tag.id, content: tag.content))
                                        .onTapGesture {
                                            viewModel.tagList.remove(at: index)
                                        }
                                }

                                TextField("태그 추가", text: $viewModel.tag)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(viewModel.tagList.isEmpty ? Color(0xACACAC) : .black)
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
                            .foregroundColor(viewModel.tagList.isEmpty ? Color(0xACACAC) : .black)
                    }
                    .padding(.horizontal, 20)

                    Divider()
                }

                //  나의 하루에 추가
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isTodayTodo.animation()) {
                            Text("나의 하루에 추가\(viewModel.isTodayTodo ? "됨" : "")")
                                .font(.system(size: 14, weight: .medium))
                                .frame(alignment: .leading)
                                .foregroundColor(viewModel.isTodayTodo ? Color(0x1DAFFF) : Color(0xACACAC))
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(
                                colors: [Constants.gradientStart, Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image("today-todo")
                            .renderingMode(.template)
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel.isTodayTodo ? Color(0x1DAFFF) : Color(0xACACAC))
                    }
                    .padding(.horizontal, 20)

                    Divider()
                }

                //  마감 설정
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isSelectedEndDate.animation()) {
                            HStack {
                                Text(viewModel.isSelectedRepeat ? "반복일" : "마감 설정")
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel.isSelectedEndDate ? Color(0x191919) : Color(0xACACAC))

                                Spacer()

                                if viewModel.isSelectedEndDate {
                                    DatePicker(
                                        selection: $viewModel.endDate,
                                        displayedComponents: [.date]
                                    ) {}
                                        .labelsHidden()
                                        .padding(.vertical, -5)
                                        .scaleEffect(0.75)
                                        .padding(.trailing, -10)
                                }
                            }
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(
                                colors: [Constants.gradientStart, Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image("date")
                            .renderingMode(.template)
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel.isSelectedEndDate ? Color(0x191919) : Color(0xACACAC))
                    }
                    .padding(.horizontal, 20)

                    if viewModel.isSelectedEndDate {
                        Label {
                            Toggle(isOn: $viewModel.isSelectedEndDateTime.animation()) {
                                HStack {
                                    Text(viewModel.isSelectedRepeat ? "시간 설정" : "마감 시간 설정")
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel.isSelectedEndDateTime ? Color(0x191919) : Color(0xACACAC))

                                    Spacer()

                                    if viewModel.isSelectedEndDateTime {
                                        DatePicker(
                                            selection: $viewModel.endDateTime,
                                            displayedComponents: [.hourAndMinute]
                                        ) {}
                                            .labelsHidden()
                                            .padding(.vertical, -5)
                                            .scaleEffect(0.75)
                                    }
                                }
                            }
                            .tint(LinearGradient(
                                gradient: Gradient(
                                    colors: [Constants.gradientStart,
                                             Constants.gradientEnd]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
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

                //  알림 설정
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isSelectedAlarm.animation()) {
                            HStack {
                                Text("알림\(viewModel.isSelectedAlarm ? "" : " 설정")")
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel.isSelectedAlarm ? Color(0x191919) : Color(0xACACAC))

                                Spacer()

                                if viewModel.isSelectedAlarm {
                                    DatePicker(selection: $viewModel.alarm) {}
                                        .labelsHidden()
                                        .padding(.vertical, -5)
                                        .scaleEffect(0.75)
                                }
                            }
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(colors: [Constants.gradientStart,
                                                        Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image("alarm")
                            .renderingMode(.template)
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel.isSelectedAlarm ? Color(0x191919) : Color(0xACACAC))
                    }
                    .padding(.horizontal, 20)

                    Divider()
                }

                //  반복 설정
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isSelectedRepeat.animation()) {
                            HStack {
                                Text("반복\(viewModel.isSelectedRepeat ? "" : " 설정")")
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel.isSelectedRepeat ? Color(0x191919) : Color(0xACACAC))
                            }
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(colors: [
                                Constants.gradientStart,
                                Constants.gradientEnd,
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image("repeat")
                            .renderingMode(.template)
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel.isSelectedRepeat ? Color(0x191919) : Color(0xACACAC))
                    }
                    .padding(.horizontal, 20)

                    if viewModel.isSelectedRepeat {
                        Picker("", selection: $viewModel.repeatOption.animation()) {
                            ForEach(RepeatOption.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 55)
                    }

                    if viewModel.isSelectedRepeat {
                        if viewModel.repeatOption == .everyYear {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
                                ForEach(viewModel.repeatYear.indices, id: \.self) { index in
                                    DayButton(content: viewModel.repeatYear[index].content, isClicked: viewModel.repeatYear[index].isClicked) {
                                        viewModel.toggleDay(repeatOption: .everyYear, index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 55)
                        } else if viewModel.repeatOption == .everyMonth {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20) {
                                ForEach(viewModel.repeatMonth.indices, id: \.self) { index in
                                    DayButton(content: viewModel.repeatMonth[index].content, isClicked: viewModel.repeatMonth[index].isClicked) {
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
                                    DayButton(content: viewModel.repeatWeek[index].content, isClicked: viewModel.repeatWeek[index].isClicked) {
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
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel.isSelectedRepeatEnd ? Color(0x191919) : Color(0xACACAC))
                                    Spacer()
                                    if viewModel.isSelectedRepeatEnd {
                                        DatePicker(
                                            selection: $viewModel.repeatEnd,
                                            in: viewModel.endDate...,
                                            displayedComponents: [.date]
                                        ) {}
                                            .labelsHidden()
                                            .scaleEffect(0.75)
                                            .padding(.vertical, -5)
                                    }
                                }
                            }
                            .tint(LinearGradient(
                                gradient: Gradient(colors: [Constants.gradientStart,
                                                            Constants.gradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
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

                //  메모 추가
                Group {
                    Label {
                        HStack {
                            Text("메모\(viewModel.memo.isEmpty ? " 추가" : "")")
                                .font(.system(size: 14, weight: .medium))
                                .frame(alignment: .leading)
                                .foregroundColor(!viewModel.memo.isEmpty ? Color(0x191919) : Color(0xACACAC))

                            Spacer()
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(
                                colors: [Constants.gradientStart,
                                         Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image("memo")
                            .renderingMode(.template)
                            .padding(.trailing, 10)
                            .foregroundColor(!viewModel.memo.isEmpty ? Color(0x191919) : Color(0xACACAC))
                    }
                    .padding(.horizontal, 20)

                    TextField("메모를 작성해주세요.",
                              text: $viewModel.memo,
                              axis: .vertical)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.leading, 45)
                        .padding(.horizontal, 20)

                    Divider()
                }

                Spacer()

                if viewModel.mode == .edit {
                    HStack(spacing: 0) {
                        Button {
                            viewModel.deleteTodo { result in
                                switch result {
                                case .success:
                                    dismissAction.callAsFunction()
                                case let .failure(failure):
                                    print("[Debug] \(failure) (\(#fileID), \(#function))")
                                }
                            }
                        } label: {
                            Text("삭제")
                                .frame(width: 74, height: 24)
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .medium))
                        }
                        .padding(.leading, 61)
                        .padding(.trailing, 120)

                        Button {
                            viewModel.updateTodo { result in
                                switch result {
                                case .success:
                                    withAnimation {
                                        dismissAction.callAsFunction()
                                    }
                                case let .failure(failure):
                                    print("[Debug] \(failure) (\(#fileID), \(#function))")
                                }
                            }
                        } label: {
                            Text("저장")
                                .frame(width: 74, height: 24)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(0x1DAFFF))
                                .disabled(viewModel.isFieldEmpty)
                        }
                        .padding(.trailing, 61)
                    }
                    .padding(.vertical, 20)
                }
            }
            .onAppear {
                UIDatePicker.appearance().minuteInterval = 5
            }
        }
        .padding(.top, isModalVisible ? 0 : 16)
        .onDisappear {
            viewModel.clear()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if !isModalVisible {
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
