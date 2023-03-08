//
//  TodoAddView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TodoAddView: View {
    struct Day {
        var content: String
        var isClicked: Bool

        init(content: String, isClicked: Bool = false) {
            self.content = content
            self.isClicked = isClicked
        }
    }

    @Environment(\.dismiss) var dismissAction
    @ObservedObject var viewModel: CheckListViewModel
    @Binding var isActive: Bool
    @State private var isRepeatModalVisible: Bool = false
    @State private var isSubTodoModalVisible: Bool = false
    @State private var todoContent: String = ""
    @State private var tag: String = ""
    @State private var isTodayTodo: Bool = false
    @State private var deadline: Date = .init()
    @State private var alarm: Date = .init()
    @State private var repeatOption: RepeatOption = .none
    @State private var memo: String = ""
    @State private var days: [Day] = [
        Day(content: "월"),
        Day(content: "화"),
        Day(content: "수"),
        Day(content: "목"),
        Day(content: "금"),
        Day(content: "토"),
        Day(content: "일"),
    ]
    @State private var subTodoList: [SubTodo] = []

    var displayRepeat: String {
        if repeatOption != .none {
            return repeatOption.rawValue
        }

        let filtered = days.filter { day in day.isClicked }

        if filtered.isEmpty {
            return ""
        }
        return "매주: " + filtered.map { day in
            day.content
        }.joined(separator: ", ")
    }

    var disableButtons: Bool {
        repeatOption != .none
    }

    init(viewModel: CheckListViewModel, isActive: Binding<Bool>) {
        self.viewModel = viewModel
        _isActive = isActive
    }

    var body: some View {
        ZStack {
            if isRepeatModalVisible {
                Modal(isActive: $isRepeatModalVisible, ratio: 1) {
                    HStack {
                        ForEach(days.indices, id: \.self) { index in
                            DayButton(disabled: disableButtons, content: days[index].content, isClicked: days[index].isClicked) {
                                days[index] = Day(content: days[index].content, isClicked: !days[index].isClicked)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .disabled(repeatOption != .none)

                    List {
                        Picker("반복 옵션", selection: $repeatOption) {
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
                            TextField("할 일을 입력해주세요", text: $todoContent)
                        }

                        Spacer()

                        Section {
                            TextField("태그를 입력해주세요", text: $tag)

                            Button {
                                isTodayTodo.toggle()
                            } label: {
                                HStack {
                                    if isTodayTodo {
                                        Image(systemName: "sun.max.fill")
                                    } else {
                                        Image(systemName: "sun.max")
                                    }
                                    Text("나의 하루에 추가")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            DatePicker("마감일", selection: $deadline)

                            DatePicker("알림 설정", selection: $alarm)
                                .onAppear {
                                    UIDatePicker.appearance().minuteInterval = 5
                                }

                            Button {
                                withAnimation {
                                    isRepeatModalVisible = true
                                }
                            } label: {
                                HStack {
                                    Text("반복 설정")
                                    Spacer()
                                    Text(displayRepeat)
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
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

                            TextField("메모 추가", text: $memo, axis: .vertical)
                                .lineLimit(8)
                        }
                    }
                    .listStyle(.plain)
                    Spacer()
                    Button {
                        viewModel.addTodo(
                            Request.Todo(
                                content: todoContent,
                                memo: memo,
                                todayTodo: isTodayTodo,
                                flag: false,
                                repeatOption: repeatOption == .none ? nil : repeatOption.rawValue,
                                repeat: repeatOption != .none || self.days.filter { day in
                                    day.isClicked
                                }.isEmpty ? nil : self.days.reduce("") { acc, day in
                                    acc + (day.isClicked ? "1" : "0")
                                },
                                tags: tag.components(separatedBy: " ").filter { tag in
                                    tag.hasSuffix("#")
                                }
                            )
                        ) { statusCode in
                            switch statusCode {
                            case 201:
                                withAnimation {
                                    dismissAction.callAsFunction()
                                    isActive = false
                                }
                            default:
                                debugPrint("[Debug]: StatusCode = \(statusCode) in TodoAddView")
                            }
                        }
                    } label: {
                        Text("추가하기")
                    }
                    .disabled(todoContent.isEmpty)
                }
            }
        }
    }
}

struct TodoAddView_Previews: PreviewProvider {
    static var previews: some View {
        TodoAddView(viewModel: CheckListViewModel(), isActive: .constant(false))
    }
}
