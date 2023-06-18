//
//  ProductivitySearchView.swift
//  Haru
//
//  Created by 이준호 on 2023/06/03.
//

import SwiftUI

struct ProductivitySearchView: View {
    @Environment(\.dismiss) var dismissAction

    @State var searchContent = ""
    @State var prevSearchContent = ""

    @StateObject var calendarVM: CalendarViewModel
    @StateObject var todoAddViewModel: TodoAddViewModel
    @StateObject var checkListVM: CheckListViewModel
    @StateObject var searchVM: SearchViewModel = .init()

    @FocusState var focus: Bool
    @State var waitingResponse: Bool = false
    @State var searchSuccess: Bool?

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let searchSuccess {
                if searchSuccess {
                    VStack(spacing: 14) {
                        Group {
                            HStack(spacing: 6) {
                                Image("calendar-mini-calendar")

                                Text("일정")
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundColor(Color(0x1DAFFF))

                                Spacer()
                            }
                            .padding(.leading, 40)

                            self.scheduleItemList()
                                .padding(.leading, 34)
                        }
                        .padding(.trailing, 20)

                        Divider()

                        Group {
                            HStack(spacing: 6) {
                                Image("calendar-mini-todo")

                                Text("할 일")
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundColor(Color(0x1DAFFF))

                                Spacer()
                            }
                            .padding(.leading, 40)

                            self.todoItemList()
                                .padding(.leading, 35)
                        }
                        .padding(.trailing, 20)
                    }
                } else {
                    VStack(spacing: 0) {
                        Image("sns-empty-search")
                            .resizable()
                            .frame(width: 165, height: 146)
                            .padding(.bottom, 54)

                        Text("해당하는 할 일 또는 일정이 없어요.")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0xACACAC))
                    }
                    .padding(.top, 160)
                }
            } else {
                VStack(spacing: 0) {
                    Image("sns-empty-search")
                        .resizable()
                        .frame(width: 165, height: 146)
                        .padding(.bottom, 54)

                    Text("할 일 또는 일정을 검색할 수 있어요.")
                        .font(.pretendard(size: 16, weight: .regular))
                        .foregroundColor(Color(0xACACAC))
                }
                .padding(.top, 160)
            }
        }
        .padding(.top, 25)
        .navigationBarBackButtonHidden()
        .customNavigationBar(leftView: {
            Button {
                self.dismissAction.callAsFunction()
            } label: {
                Image("back-button")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
        }, rightView: {
            HStack(spacing: 8) {
                Image("search")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color(0xACACAC))
                TextField("검색어를 입력하세요", text: self.$searchContent)
                    .disableAutocorrection(true)
                    .font(.pretendard(size: 16, weight: .regular))
                    .focused(self.$focus)
                    .onSubmit {
                        if self.searchContent != "" {
                            self.waitingResponse = true
                            self.searchVM.searchTodoAndSchedule(
                                searchContent: self.searchContent
                            ) { success in
                                self.prevSearchContent = self.searchContent
                                self.searchContent = ""
                                self.waitingResponse = false
                                self.searchSuccess = success
                            }
                        }
                    }
                    .disabled(self.waitingResponse)
                Spacer()
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .background(Color(0xF1F1F5))
            .cornerRadius(10)
        })
    }

    @ViewBuilder
    func scheduleItemList() -> some View {
        ForEach(self.searchVM.scheduleList, id: \.id) { schedule in
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .fill(Color(schedule.category?.color))
                    .frame(width: 20, height: 20)
                    .padding(5)

                NavigationLink {
                    ScheduleFormView(
                        scheduleFormVM:
                        ScheduleFormViewModel(
                            schedule: schedule,
                            categoryList: self.calendarVM.categoryList,
                            successAction: {
                                self.searchVM.searchTodoAndSchedule(
                                    searchContent: self.prevSearchContent
                                ) { success in
                                    self.searchSuccess = success
                                }
                            }
                        ),
                        isSchModalVisible: .constant(false)
                    )
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 0) {
                            let stringList = self.splitContent(content: schedule.content, searchString: self.prevSearchContent)
                            ForEach(stringList.indices, id: \.self) { idx in
                                Text("\(stringList[idx].0)")
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundColor(stringList[idx].1 ? Color(0x1DAFFF) : Color(0x191919))
                            }
                        }
                        Text(schedule.isAllDay ? "하루 종일" :
                            "\(schedule.repeatStart.getDateFormatString("M월 d일 a hh:mm")) - \(schedule.repeatEnd.getDateFormatString("M월 d일 a hh:mm"))"
                        )
                        .font(.pretendard(size: 12, weight: .regular))
                        .foregroundColor(Color(0x191919))
                    }
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    func todoItemList() -> some View {
        ForEach(self.$searchVM.todoList) { $todo in
            NavigationLink {
                TodoAddView(viewModel: self.todoAddViewModel)
                    .onAppear {
                        self.todoAddViewModel.applyTodoData(
                            todo: todo,
                            at: todo.at
                        )
                    }
            } label: {
                TodoView(
                    checkListViewModel: self.checkListVM,
                    todo: todo,
                    at: todo.at,
                    contentWords: self.splitContent(content: todo.content, searchString: self.prevSearchContent)
                ) {
                    // completeAction
                    withAnimation {
                        todo.completed.toggle()
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.searchVM.searchTodoAndSchedule(
                            searchContent: self.prevSearchContent
                        ) { success in
                            self.searchSuccess = success
                        }
                    }
                } updateAction: {
                    // updateAction
                    withAnimation {
                        todo.flag.toggle()
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.searchVM.searchTodoAndSchedule(
                            searchContent: self.prevSearchContent
                        ) { success in
                            self.searchSuccess = success
                        }
                    }
                }
            }
            .padding(.leading, -40)
        }
    }

    func splitContent(
        content: String,
        searchString: String
    ) -> [(String, Bool)] {
        var result: [(String, Bool)] = []

        var preString: String
        var sufString: String = content

        for str in StringHelper.matches(for: "(?i)\(searchString)", in: content) {
            if let rangeS = sufString.range(of: str) {
                let dist = sufString.distance(from: sufString.startIndex, to: rangeS.lowerBound)

                preString = String(sufString.prefix(dist))
                if preString != "" {
                    result.append((preString, false))
                }
                result.append((searchString, true))
                sufString = String(sufString.suffix(sufString.count - (dist + searchString.count)))
            }
        }

        if sufString != "" {
            result.append((sufString, false))
        }

        let tmpResult = result
        var p = 0
        for (col, str) in tmpResult.enumerated() {
            var data = ""
            for _ in str.0 {
                data += String(content[content.index(content.startIndex, offsetBy: p)])
                p += 1
            }
            result[col].0 = data
        }

        return result
    }
}
