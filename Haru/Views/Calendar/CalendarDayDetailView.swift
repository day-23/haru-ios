//
//  CalendarDayDetailView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI

struct CalendarDayDetailView: View {
    @State private var content: String = ""
    
    @Binding var currentScheduleList: [Schedule]
    @Binding var currentTodoList: [Todo]
    @Binding var currentDate: Date
    
    var body: some View {
        VStack {
            HStack {
                Text("\(currentDate.month)월 \(currentDate.day)일")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
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
                    VStack(spacing: 20) {
                        HStack {
                            Image("calendar")
                            Text("일정")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(currentScheduleList.indices, id: \.self) { index in
                            HStack(spacing: 20) {
                                Circle()
                                    .fill(Color(currentScheduleList[index].category?.color, true))
                                    .frame(width: 20, height: 20)
                                VStack(alignment: .leading) {
                                    Text("\(currentScheduleList[index].content)")
                                    Text("하루종일")
                                        .font(.pretendard(size: 12, weight: .regular))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Divider()
                        
                        HStack {
                            Image("checkMark")
                            Text("할일")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(currentTodoList.indices, id: \.self) { index in
                            HStack(spacing: 20) {
                                Circle()
                                    .strokeBorder()
                                    .frame(width: 20, height: 20)
                                Text("\(currentTodoList[index].content)")
                                Spacer()
                                Image("star")
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 30)
                    }
                } // ScrollView
                
                VStack {
                    Spacer()
                    
                    HStack {
                        TextField("\(currentDate.month)월 \(currentDate.day)일 일정 추가", text: $content)
                            .frame(height: 20)
                            .padding(10)
                            .padding(.horizontal, 12)
                            .background(.gray4)
                            .cornerRadius(8)
                        
                        Button {
                            print("hello")
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 28, height: 28)
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
