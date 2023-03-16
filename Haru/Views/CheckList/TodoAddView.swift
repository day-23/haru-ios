//
//  TodoAddView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TodoAddView: View {
    @ObservedObject var viewModel: TodoAddViewModel
    @Binding var isActive: Bool

    var body: some View {
        ScrollView {
            VStack {
                // Todo, SubTodo 입력 View
                VStack(alignment: .leading) {
                    TextField("투두 입력", text: $viewModel.todoContent)
                        .padding(.horizontal, 20)
                        .font(.title)
                        .bold()

                    ForEach(viewModel.subTodoList.indices,
                            id: \.self) { index in
                        HStack {
                            Text("∙")
                            TextField("", text: $viewModel.subTodoList[index])
                            Button {
                                viewModel.subTodoList.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(Constants.lightGray)
                            }
                        }
                        Divider()
                    }
                    .padding(.horizontal, 30)

                    Button {
                        viewModel.subTodoList.append("")
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
                                ForEach(viewModel.tagList.indices,
                                        id: \.self) { index in
                                    TagView(Tag(
                                        id: viewModel.tagList[index]
                                            .description,
                                        content: viewModel.tagList[index]
                                            .description
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
                        Toggle(isOn: $viewModel.isTodayTodo) {
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
                        Toggle(isOn: $viewModel.isSelectedEndDate) {
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
                            Toggle(isOn: $viewModel.isSelectedEndDateTime) {
                                HStack {
                                    Text("마감 시간 설정")
                                        .frame(alignment: .leading)
                                        .foregroundColor(viewModel
                                            .isSelectedEndDateTime ? .black :
                                            Constants.lightGray)

                                    Spacer()

                                    if viewModel.isSelectedEndDateTime {
                                        DatePicker(
                                            selection: $viewModel.endDateTime,
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
                                        .gradientStart, Constants.gradientEnd]),
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
                        Toggle(isOn: $viewModel.isSelectedAlarm) {
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
                        Toggle(isOn: $viewModel.isSelectedRepeat) {
                            HStack {
                                Text("반복 설정")
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel
                                        .isSelectedRepeat ? .black : Constants
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
                        Image(systemName: "repeat")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel
                                .isSelectedRepeat ? .black : Constants
                                .lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    Divider()
                }

                // 메모 추가
                Group {
                    Label {
                        Toggle(isOn: $viewModel.isWritedMemo) {
                            HStack {
                                Text("메모 추가")
                                    .frame(alignment: .leading)
                                    .foregroundColor(viewModel
                                        .isWritedMemo ? .black : Constants
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
                        Image(systemName: "note")
                            .padding(.trailing, 10)
                            .foregroundColor(viewModel
                                .isWritedMemo ? .black : Constants.lightGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    if viewModel.isWritedMemo {
                        TextField(
                            "메모를 작성해주세요.",
                            text: $viewModel.memo,
                            axis: .vertical
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }

                    Divider()
                }

                Button {
                    switch viewModel.mode {
                    case .add:
                        viewModel.addTodo { result in
                            switch result {
                            case .success:
                                withAnimation {
                                    isActive = false
                                }
                            case let .failure(failure):
                                print("[Debug] \(failure) (TodoAddView)")
                            }
                        }
                    case .edit:
                        viewModel.updateTodo { result in
                            switch result {
                            case let .success(success):
                                withAnimation {
                                    isActive = false
                                }
                            case let .failure(failure):
                                print("[Debug] \(failure) (TodoAddView)")
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
        .onDisappear {
            viewModel.clear()
        }
    }
}

struct TodoAddView_Previews: PreviewProvider {
    static var previews: some View {
        TodoAddView(
            viewModel: TodoAddViewModel(
                checkListViewModel: CheckListViewModel()
            ),
            isActive: .constant(true)
        )
    }
}
