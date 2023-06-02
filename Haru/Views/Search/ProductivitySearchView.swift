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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Group {
                    HStack(spacing: 6) {
                        Image("calendar")
                            .resizable()
                            .frame(width: 28, height: 28)

                        Text("일정")
                            .font(.pretendard(size: 16, weight: .bold))
                            .foregroundColor(Color(0x1DAFFF))
                        
                        Spacer()
                    }
                    
                    scheduleItemList()
                }
                .padding(.leading, 40)
                .padding(.trailing, 20)
                
                Divider()
                
                Group {
                    HStack(spacing: 6) {
                        Image("checkMark")
                            .resizable()
                            .frame(width: 28, height: 28)
                        
                        Text("할일")
                            .font(.pretendard(size: 16, weight: .bold))
                            .foregroundColor(Color(0x1DAFFF))
                        
                        Spacer()
                    }
                    
                    todoItemList()
                }
                .padding(.leading, 40)
                .padding(.trailing, 20)
            }
        }
        .padding(.top, 25)
        .navigationBarBackButtonHidden()
        .customNavigationBar(leftView: {
            Button {
                dismissAction.callAsFunction()
            } label: {
                Image("back-button")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
        }, rightView: {
            HStack(spacing: 8) {
                Image("magnifyingglass")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color(0xACACAC))
                TextField("검색어를 입력하세요", text: $searchContent)
                    .disableAutocorrection(true)
                    .font(.pretendard(size: 16, weight: .regular))
                    .focused($focus)
                    .onSubmit {
                        if searchContent != "" {
                            waitingResponse = true
                            searchVM.searchTodoAndSchedule(searchContent: searchContent) {
                                prevSearchContent = searchContent
                                searchContent = ""
                                waitingResponse = false
                            }
                        }
                    }
                    .disabled(waitingResponse)
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(0xF1F1F5))
            .cornerRadius(10)
        })
    }
    
    @ViewBuilder
    func scheduleItemList() -> some View {
        ForEach(searchVM.scheduleList, id: \.id) { schedule in
            HStack(alignment: .center) {
                Circle()
                    .fill(Color(schedule.category?.color))
                    .frame(width: 20, height: 20)
                    .padding(5)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        let stringList = splitContent(content: schedule.content, searchString: prevSearchContent)
                        ForEach(stringList.indices, id: \.self) { idx in
                            Text("\(stringList[idx].0)")
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(stringList[idx].1 ? Color(0x1DAFFF) : Color(0x191919))
                        }
                    }
                    Text(schedule.isAllDay ? "하루 종일" :
                        CalendarHelper.isSameDay(
                            date1: schedule.repeatStart,
                            date2: schedule.repeatEnd
                        ) ?
                        "\(schedule.repeatStart.getDateFormatString("a hh:mm")) - \(schedule.repeatEnd.getDateFormatString("a hh:mm"))"
                        :
                        "\(schedule.repeatStart.getDateFormatString("M월 d일 a hh:mm")) - \(schedule.repeatEnd.getDateFormatString("M월 d일 a hh:mm"))"
                    )
                    .font(.pretendard(size: 12, weight: .regular))
                    .foregroundColor(Color(0x191919))
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func todoItemList() -> some View {
        ForEach(searchVM.todoList, id: \.id) { todo in
            NavigationLink {
                TodoAddView(viewModel: todoAddViewModel)
                    .onAppear {
                        todoAddViewModel.applyTodoData(
                            todo: todo,
                            at: todo.at
                        )
                    }
            } label: {
                SearchTodoView(
                    checkListViewModel: checkListVM,
                    todo: todo,
                    at: todo.at,
                    contentWords: splitContent(content: todo.content, searchString: prevSearchContent)
                ) {
                    // completeAction
                    searchVM.searchTodoAndSchedule(searchContent: prevSearchContent) {}
                } updateAction: {
                    // updateAction
                    searchVM.searchTodoAndSchedule(searchContent: prevSearchContent) {}
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
