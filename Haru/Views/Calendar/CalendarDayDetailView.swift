//
//  CalendarDayDetailView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI

struct CalendarDayDetailView: View {
    @StateObject var calendarVM: CalendarViewModel
    @StateObject var todoAddViewModel: TodoAddViewModel
    @StateObject var checkListVM: CheckListViewModel
    var row: Int
    
    @State private var content: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("\(calendarVM.pivotDateList[row].getDateFormatString("M월 dd일 E요일"))")
                    .foregroundColor(.white)
                    .font(.pretendard(size: 20, weight: .bold))
                Spacer()
                Group {
                    Button {
                        print("날짜 하루 낮추기")
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Button {
                        print("날짜 하루 낮추기")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .tint(.white)
            }
            .padding()
            .background(.gradation2)
            
            Spacer()
            
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image("calendar-schedule")
                            Text("일정")
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(.gradientStart1)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
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
                                HStack(spacing: 20) {
                                    Circle()
                                        .fill(Color(schedule.category?.color))
                                        .frame(width: 14, height: 14)
                                    VStack(alignment: .leading) {
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
                                .padding(.horizontal, 20)
                            }
                            .disabled(schedule.category == Global.shared.holidayCategory)
                            .foregroundColor(Color(0x191919))
                        }
                        
                        Divider()
                        
                        HStack {
                            Image("calendar-todo")
                            Text("할일")
                                .foregroundColor(.gradientStart1)
                                .font(.pretendard(size: 14, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
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
                                    at: calendarVM.todoList[row][index].at,
                                    isMiniCalendar: true
                                ) {
                                    calendarVM.getRefreshProductivityList()
                                    calendarVM.getCurMonthSchList(calendarVM.dateList)
                                } updateAction: {
                                    calendarVM.getRefreshProductivityList()
                                    calendarVM.getCurMonthSchList(calendarVM.dateList)
                                }
                            }
                            .tint(.mainBlack)
                            .padding(.leading, 5)
                        }
                        
                        Spacer()
                            .frame(height: 30)
                    }
                } // ScrollView
                
                VStack {
                    Spacer()
                    
                    HStack {
                        TextField("\(calendarVM.pivotDateList[row].month)월 \(calendarVM.pivotDateList[row].day)일 일정 추가", text: $content)
                            .font(.pretendard(size: 14, weight: .light))
                            .frame(height: 20)
                            .padding(10)
                            .padding(.horizontal, 12)
                            .background(.gray4)
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
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            
            Rectangle()
                .fill(.gradation2)
                .frame(height: 30)
        }
        .background(.white)
    }
}
