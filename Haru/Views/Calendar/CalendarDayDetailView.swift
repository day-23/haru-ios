//
//  CalendarDayDetailView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI

struct CalendarDayDetailView: View {
    var calendarVM: CalendarViewModel
//    @StateObject var scheduleVM: ScheduleFormViewModel
    var todoAddViewModel: TodoAddViewModel
    
    @State private var content: String = ""
    
    var row: Int
    
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
                            Image("calendar")
                            Text("일정")
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(.gradientStart1)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(calendarVM.scheduleList[row].indices, id: \.self) { index in
                            NavigationLink {
                                ScheduleFormView(scheduleFormVM: ScheduleFormViewModel(calendarVM: calendarVM, schedule: calendarVM.scheduleList[row][index]), isSchModalVisible: .constant(false), selectedIndex: row)
                            } label: {
                                HStack(spacing: 20) {
                                    Circle()
                                        .fill(Color(calendarVM.scheduleList[row][index].category?.color, true))
                                        .frame(width: 14, height: 14)
                                    VStack(alignment: .leading) {
                                        Text("\(calendarVM.scheduleList[row][index].content)")
                                            .font(.pretendard(size: 14, weight: .bold))
                                        Text(calendarVM.scheduleList[row][index].isAllDay ? "하루 종일" : "\(calendarVM.scheduleList[row][index].repeatStart.getDateFormatString("a hh:mm")) - \(calendarVM.scheduleList[row][index].repeatEnd.getDateFormatString("a hh:mm"))")
                                            .font(.pretendard(size: 10, weight: .regular))
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .tint(.mainBlack)
                        }
                        
                        Divider()
                        
                        HStack {
                            Image("checkMark")
                            Text("할일")
                                .foregroundColor(.gradientStart1)
                                .font(.pretendard(size: 14, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(calendarVM.todoList[row].indices, id: \.self) { index in
                            NavigationLink {
                                Text("todo list 수정")
                            } label: {
                                HStack(spacing: 20) {
                                    Image("check-circle")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading) {
                                        Text("\(calendarVM.todoList[row][index].content)")
                                            .font(.pretendard(size: 14, weight: .bold))
                                        HStack(spacing: 8) {
                                            ForEach(calendarVM.todoList[row][index].tags.prefix(5)) { tag in
                                                Text("\(tag.content)")
                                                    .font(.pretendard(size: 10, weight: .regular))
                                            }
                                        }
                                    }
                                    .frame(height: 28, alignment: .leading)
                                    Spacer()
                                    Image(calendarVM.todoList[row][index].flag ? "star-check" : "star")
                                        .frame(width: 14, height: 14)
                                }
                                .padding(.horizontal, 20)
                            }
                            .tint(.mainBlack)
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
                            ScheduleFormViewModel(calendarVM: calendarVM).addEasySchedule(content: content, pivotDate: calendarVM.pivotDate)
                            self.content = ""
                        } label: {
                            Image("plus-button")
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
