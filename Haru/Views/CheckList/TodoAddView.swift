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
    @Binding var isActive: Bool
    @State private var isRepeatModalVisible: Bool = false
    @State private var isSubTodoModalVisible: Bool = false

    init(viewModel: TodoAddViewModel, isActive: Binding<Bool>) {
        self.viewModel = viewModel
        _isActive = isActive
    }

    var body: some View {
        ZStack {
            if isRepeatModalVisible {
                Modal(isActive: $isRepeatModalVisible, ratio: 1) {
                    HStack {
                        ForEach(viewModel.days.indices, id: \.self) { index in
                            DayButton(disabled: viewModel.disableButtons, content: viewModel.days[index].content, isClicked: viewModel.days[index].isClicked) {
                                viewModel.days[index] = Day(content: viewModel.days[index].content, isClicked: !viewModel.days[index].isClicked)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .disabled(viewModel.repeatOption != .none)

                    List {
                        Picker("반복 옵션", selection: $viewModel.repeatOption) {
                            ForEach(RepeatOption.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    .listStyle(.inset)
                }
                .transition(.modal)
            } else if isSubTodoModalVisible {
                Modal(isActive: $isSubTodoModalVisible, ratio: 1) {}
                    .transition(.modal)
            } else {
                VStack {
                    List {
                        Section {
                            TextField("할 일을 입력해주세요", text: $viewModel.todoContent)
                        }

                        Spacer()

                        Section {
                            TextField("태그를 입력해주세요", text: $viewModel.tag)

                            Button {
                                viewModel.isTodayTodo.toggle()
                            } label: {
                                HStack {
                                    if viewModel.isTodayTodo {
                                        Image(systemName: "sun.max.fill")
                                            .foregroundColor(.orange)
                                    } else {
                                        Image(systemName: "sun.max")
                                    }
                                    Text("나의 하루에 추가")
                                }
                            }

                            Button {
                                viewModel.flag.toggle()
                            } label: {
                                HStack {
                                    if viewModel.flag {
                                        Image(systemName: "flag.fill")
                                            .foregroundColor(.red)
                                    } else {
                                        Image(systemName: "flag")
                                    }
                                    Text("중요한 일")
                                }
                            }

                            HStack {
                                Button {
                                    withAnimation {
                                        viewModel.isSelectedEndDate.toggle()
                                    }
                                } label: {
                                    Text("마감일 설정")
                                        .foregroundColor(.blue)
                                }

                                if viewModel.isSelectedEndDate {
                                    DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                                }
                            }

                            if viewModel.isSelectedEndDate {
                                HStack {
                                    Button {
                                        viewModel.isSelectedEndDateTime.toggle()
                                    } label: {
                                        Text("마감일 시간 설정")
                                            .foregroundColor(.blue)
                                    }

                                    if viewModel.isSelectedEndDateTime {
                                        DatePicker("", selection: $viewModel.endDateTime, displayedComponents: .hourAndMinute)
                                    }
                                }
                            }

                            HStack {
                                Button {
                                    viewModel.isSelectedAlarm.toggle()
                                } label: {
                                    Text("알림 설정")
                                        .foregroundColor(.blue)
                                }

                                if viewModel.isSelectedAlarm {
                                    DatePicker("", selection: $viewModel.alarm)
                                }
                            }

                            Button {
                                withAnimation {
                                    isRepeatModalVisible = true
                                }
                            } label: {
                                HStack {
                                    Text("반복 설정")
                                    Spacer()
                                    Text(viewModel.displayRepeat)
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                }
                            }

                            if !viewModel.displayRepeat.isEmpty {
                                HStack {
                                    Button {
                                        viewModel.isSelectedRepeatEnd.toggle()
                                    } label: {
                                        Text("반복 끝 날짜 설정")
                                            .foregroundColor(.blue)
                                    }

                                    if viewModel.isSelectedRepeatEnd {
                                        DatePicker("", selection: $viewModel.repeatEnd, displayedComponents: .date)
                                    }
                                }
                            }

                            Button {
                                withAnimation {
                                    isSubTodoModalVisible = true
                                }
                            } label: {
                                HStack {
                                    Text("하위 항목")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }

                            TextField("메모 추가", text: $viewModel.memo)
                                .lineLimit(1)
                        }
                    }
                    .listStyle(.plain)
                    Spacer()
                    Button {
                        viewModel.addTodo { statusCode in
                            switch statusCode {
                            case 201:
                                withAnimation {
                                    dismissAction.callAsFunction()
                                    isActive = false
                                }
                            default:
                                print("[Debug] StatusCode = \(statusCode) in TodoAddView")
                            }
                        }
                    } label: {
                        Text("추가하기")
                    }
                    .disabled(viewModel.todoContent.isEmpty)
                }
            }
        }
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
    }
}
