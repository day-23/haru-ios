//
//  CalendarDayDetailView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI
import SwiftUIPager

struct CalendarDayDetailView: View {
    @StateObject var calendarVM: CalendarViewModel
    @StateObject var todoAddViewModel: TodoAddViewModel
    @StateObject var checkListVM: CheckListViewModel
    @StateObject var page: Page
    var row: Int
    
    @State private var content: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(calendarVM.pivotDateList[row].getDateFormatString("dd일 E요일"))")
                    .foregroundColor(Color(0xFDFDFD))
                    .font(.pretendard(size: 24, weight: .bold))
                
                Spacer()
                
                Group {
                    Button {
                        withAnimation {
                            page.update(.new(index: page.index - 1))
                        }
                    } label: {
                        Image("calendar-next-button")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .rotationEffect(Angle(degrees: 180))
                    }
                    Button {
                        withAnimation {
                            page.update(.new(index: page.index + 1))
                        }
                    } label: {
                        Image("calendar-next-button")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .tint(Color(0xFDFDFD))
            }
            .padding(.horizontal, 24)
            .padding(.top, 25)
            .padding(.bottom, 15)
            
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Image("calendar-mini-calendar")
                            Text("일정")
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(Color(0x1DAFFF))
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        
                        ForEach(calendarVM.scheduleList[row].indices, id: \.self) { index in
                            let schedule = calendarVM.scheduleList[row][index]
                            NavigationLink {
                                ScheduleFormView(
                                    scheduleFormVM: ScheduleFormViewModel(
                                        schedule: schedule,
                                        categoryList: calendarVM.categoryList
                                    ) {
                                        calendarVM.getCurMonthSchList(calendarVM.dateList)
                                        calendarVM.getRefreshProductivityList()
                                    },
                                    isSchModalVisible: .constant(false)
                                )
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(schedule.category?.color))
                                        .frame(width: 18, height: 18)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(schedule.content)")
                                            .font(.pretendard(size: 16, weight: .bold))
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
                                    }
                                }
                                .padding(.horizontal, 29)
                            }
                            .disabled(schedule.category == Global.shared.holidayCategory)
                            .foregroundColor(Color(0x191919))
                            .padding(.top, 11)
                        }
                        
                        Divider()
                            .padding(.top, 17)
                            .padding(.bottom, 10)
                        
                        HStack(spacing: 12) {
                            Image("calendar-mini-todo")
                            Text("할 일")
                                .foregroundColor(Color(0x1DAFFF))
                                .font(.pretendard(size: 16, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 4)
                        
                        ForEach(calendarVM.todoList[row].indices, id: \.self) { index in
                            NavigationLink {
                                TodoAddView(
                                    viewModel: todoAddViewModel
                                )
                                .onAppear {
                                    todoAddViewModel.applyTodoData(
                                        todo: calendarVM.todoList[row][index],
                                        at: calendarVM.todoList[row][index].at
                                    )
                                }
                            } label: {
                                TodoView(
                                    checkListViewModel: checkListVM,
                                    todo: calendarVM.todoList[row][index],
                                    backgroundColor: Color(0xFDFDFD),
                                    at: calendarVM.todoList[row][index].at,
                                    isMiniCalendar: true
                                ) {
                                    withAnimation {
                                        calendarVM.todoList[row][index].completed.toggle()
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        calendarVM.getRefreshProductivityList()
                                        calendarVM.getCurMonthSchList(calendarVM.dateList)
                                    }
                                } updateAction: {
                                    withAnimation {
                                        calendarVM.todoList[row][index].flag.toggle()
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        calendarVM.getRefreshProductivityList()
                                        calendarVM.getCurMonthSchList(calendarVM.dateList)
                                    }
                                }
                            }
                            .tint(.mainBlack)
                            .padding(.leading, 11)
                            .padding(.top, 11)
                        }
                        
                        Spacer()
                            .frame(height: 47)
                    }
                } // ScrollView
                
                VStack {
                    Spacer()
                    
                    HStack {
                        TextField("\(calendarVM.pivotDateList[row].month)월 \(calendarVM.pivotDateList[row].day)일 일정 추가", text: $content)
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x191919))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(0xF1F1F5))
                            .cornerRadius(8)
                        
                        Button {
                            ScheduleFormViewModel(
                                selectionSet: calendarVM.selectionSet,
                                categoryList: calendarVM.categoryList,
                                successAction: {
                                    calendarVM.getCurMonthSchList(calendarVM.dateList)
                                    calendarVM.getRefreshProductivityList()
                                }
                            ).addEasySchedule(content: content, pivotDate: calendarVM.pivotDate)
                            content = ""
                        } label: {
                            Image("calendar-add-button-small")
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.trailing, 4)
                }
                .padding(.bottom, 10)
            }
            .background(Color(0xFDFDFD))
        }
        .background(
            Image("calendar-card-background")
        )
    }
}
