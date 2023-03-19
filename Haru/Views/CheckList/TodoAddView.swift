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

    init(viewModel: TodoAddViewModel, isModalVisible: Binding<Bool>? = nil) {
        self.viewModel = viewModel
        _isModalVisible = isModalVisible ?? .constant(false)
    }

    var body: some View {
        ScrollView {
            VStack {
                // Todo, SubTodo 입력 View
                VStack(alignment: .leading) {
                    HStack {
                        if !isModalVisible {
                            Button {
                                // TODO: Complete API 연결
                            } label: {
                                Circle()
                                    .strokeBorder(Color(0x707070), lineWidth: 1)
                                    .frame(width: 20, height: 20)
                            }
                        }

                        TextField("투두 입력", text: $viewModel.todoContent)
                            .padding(.leading, isModalVisible ? 26 : 12)
                            .font(.system(size: 24, weight: .medium))

                        if !isModalVisible {
                            Button {
                                // TODO: Delete API 연결
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(Color(0x000000, opacity: 0.5))
                                    .padding(.trailing, 2)
                            }
                        }
                    }
                    .padding(.bottom, 15)

                    ForEach(viewModel.subTodoList.indices, id: \.self) { index in
                        HStack {
                            Text("∙")
                            TextField("", text: $viewModel.subTodoList[index].content)
                                .font(.system(size: 14, weight: .light))
                            Button {
                                viewModel.removeSubTodo(index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(Constants.lightGray)
                            }
                        }
                        .padding(.horizontal, 30)

                        Divider()
                    }

                    Button {
                        viewModel.createSubTodo()
                    } label: {
                        Label {
                            Text("하위 항목 추가")
                        } icon: {
                            Image(systemName: "plus")
                        }
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(Constants.lightGray)

                    Divider()
                }
                .padding(.horizontal, 30)

                // Tag 입력 View
                Group {
                    Label {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(
                                    Array(zip(viewModel.tagList.indices, viewModel.tagList)),
                                    id: \.0
                                ) { index, tag in
                                    TagView(Tag(
                                        id: tag.id,
                                        content: tag.content
                                    ))
                                    .onTapGesture {
                                        viewModel.tagList.remove(at: index)
                                    }
                                }

                                TextField("태그", text: $viewModel.tag)
                                    .foregroundColor(viewModel.tagList
                                        .isEmpty ? Constants.lightGray : .black)
                                    .onChange(
                                        of: viewModel.tag,
                                        perform: viewModel.onChangeTag
                                    )
                                    .onSubmit(viewModel.onSubmitTag)
                            }
                            .padding(1)
                        }
                    } icon: {
                        Image(systemName: "tag")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel.tagList
                                .isEmpty ? Constants.lightGray : .black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    Divider()
                }

                // 나의 하루에 추가
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isTodayTodo.animation()) {
                            Text("나의 하루에 추가")
                                .frame(alignment: .leading)
                                .foregroundColor(viewModel
                                    .isTodayTodo ? .black : Constants.lightGray)
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(colors: [Constants.gradientStart,
                                                        Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image(systemName: "sun.max")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel
                                .isTodayTodo ? .black : Constants.lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    Divider()
                }

                // 마감 설정
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isSelectedEndDate.animation()) {
                            HStack {
                                Text("마감 설정")
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel
                                        .isSelectedEndDate ? .black : Constants
                                        .lightGray)

                                Spacer()

                                if viewModel.isSelectedEndDate {
                                    DatePicker(
                                        selection: $viewModel.endDate,
                                        displayedComponents: [.date]
                                    ) {}
                                        .labelsHidden()
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
                        Image(systemName: "calendar")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel
                                .isSelectedEndDate ? .black : Constants
                                .lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    if viewModel.isSelectedEndDate {
                        Label {
                            Toggle(isOn: $viewModel.isSelectedEndDateTime
                                .animation()) {
                                    HStack {
                                        Text("마감 시간 설정")
                                            .frame(alignment: .leading)
                                            .foregroundColor(viewModel
                                                .isSelectedEndDateTime ?
                                                .black :
                                                Constants.lightGray)

                                        Spacer()

                                        if viewModel.isSelectedEndDateTime {
                                            DatePicker(
                                                selection: $viewModel
                                                    .endDateTime,
                                                displayedComponents: [
                                                    .hourAndMinute,
                                                ]
                                            ) {}
                                                .labelsHidden()
                                                .padding(.vertical, -5)
                                        }
                                    }
                                }
                                .tint(LinearGradient(
                                    gradient: Gradient(colors: [Constants
                                            .gradientStart,
                                        Constants.gradientEnd]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        } icon: {
                            Image(systemName: "clock")
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel
                                    .isSelectedEndDateTime ? .black : Constants
                                    .lightGray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }

                    Divider()
                }

                // 알림 설정
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isSelectedAlarm.animation()) {
                            HStack {
                                Text("알림 설정")
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel
                                        .isSelectedAlarm ? .black : Constants
                                        .lightGray)
                            }
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(colors: [Constants.gradientStart,
                                                        Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image(systemName: "bell")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel
                                .isSelectedAlarm ? .black : Constants.lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    if viewModel.isSelectedAlarm {
                        DatePicker(selection: $viewModel.alarm) {}
                            .labelsHidden()
                            .padding(.vertical, 5)
                    }

                    Divider()
                }

                // 반복 설정
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isSelectedRepeat.animation()) {
                            HStack {
                                Text("반복 설정")
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel
                                        .isSelectedRepeat ? .black : Constants
                                        .lightGray)
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
                        Image(systemName: "repeat")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel
                                .isSelectedRepeat ? .black : Constants
                                .lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    if viewModel.isSelectedRepeat {
                        Picker("", selection: $viewModel.repeatOption.animation()) {
                            ForEach(RepeatOption.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }

                    if viewModel.isSelectedRepeat {
                        if viewModel.repeatOption == .everyYear {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
                                ForEach(viewModel.repeatYear.indices, id: \.self) { index in
                                    DayButton(content: viewModel.repeatYear[index].content, isClicked: viewModel.repeatYear[index].isClicked) {
                                        viewModel.toggleDay(.everyYear, index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                        } else if viewModel.repeatOption == .everyMonth {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20) {
                                ForEach(viewModel.repeatMonth.indices, id: \.self) { index in
                                    DayButton(content: viewModel.repeatMonth[index].content, isClicked: viewModel.repeatMonth[index].isClicked) {
                                        viewModel.toggleDay(.everyMonth, index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                        } else if viewModel.repeatOption == .everySecondWeek ||
                            viewModel.repeatOption == .everyWeek
                        {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                ForEach(viewModel.repeatWeek.indices, id: \.self) { index in
                                    DayButton(content: viewModel.repeatWeek[index].content, isClicked: viewModel.repeatWeek[index].isClicked) {
                                        viewModel.toggleDay(.everyWeek, index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                        }

                        Label {
                            Toggle(isOn: $viewModel.isSelectedRepeatEnd.animation()) {
                                HStack {
                                    Text("반복 종료일")
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel
                                            .isSelectedRepeatEnd ? .black : Constants
                                            .lightGray)
                                    Spacer()
                                    if viewModel.isSelectedRepeatEnd {
                                        DatePicker(selection: $viewModel.repeatEnd, displayedComponents: [.date]) {}
                                            .labelsHidden()
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
                                .padding(.trailing, 10)
                                .foregroundColor(viewModel
                                    .isSelectedRepeatEnd ? .black : Constants
                                    .lightGray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }

                    Divider()
                }

                // 메모 추가
                Group {
                    Label {
                        HStack {
                            Text("메모 추가")
                                .frame(alignment: .leading)
                                .foregroundColor(!viewModel.memo.isEmpty ?
                                    .black : Constants.lightGray)

                            Spacer()
                        }
                        .tint(LinearGradient(
                            gradient: Gradient(colors: [Constants.gradientStart,
                                                        Constants.gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    } icon: {
                        Image(systemName: "note")
                            .padding(.trailing, 10)
                            .foregroundColor(!viewModel.memo.isEmpty ?
                                .black : Constants.lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    TextField(
                        "메모를 작성해주세요.",
                        text: $viewModel.memo,
                        axis: .vertical
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    Divider()
                }

                Button {
                    switch viewModel.mode {
                    case .add:
                        viewModel.addTodo { result in
                            switch result {
                            case .success:
                                withAnimation {
                                    if isModalVisible {
                                        isModalVisible = false
                                    } else {
                                        dismissAction.callAsFunction()
                                    }
                                }
                            case let .failure(failure):
                                print("[Debug] \(failure) (\(#fileID), \(#function))")
                            }
                        }
                    case .edit:
                        viewModel.updateTodo { result in
                            switch result {
                            case .success:
                                withAnimation {
                                    if isModalVisible {
                                        isModalVisible = false
                                    } else {
                                        dismissAction.callAsFunction()
                                    }
                                }
                            case let .failure(failure):
                                print("[Debug] \(failure) (\(#fileID), \(#function))")
                            }
                        }
                    }
                } label: {
                    Text("\(viewModel.mode == .add ? "추가" : "수정")")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .disabled(viewModel.todoContent.isEmpty)
                }

                Spacer()
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
                    HStack {
                        Button {
                            dismissAction.callAsFunction()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }

                        Text("나의 하루")
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }
}
