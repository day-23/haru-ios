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
                    .font(.pretendard(size: 16, weight: .regular))
                    .focused($focus)
                    .onSubmit {
                        if searchContent != "" {
                            waitingResponse = true
                            searchVM.searchTodoAndSchedule(searchContent: searchContent) {
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
                    Text("\(schedule.content)")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))
                    
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
//        ForEach(, id: \.self) { idx in
//            TodoView(checkListViewModel: checkListVM, todo:)
//        }
    }
}
