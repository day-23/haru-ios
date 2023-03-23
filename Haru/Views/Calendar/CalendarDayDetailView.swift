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
    
    var index: Int
    
    var body: some View {
        VStack {
            HStack {
                Text("\(index)")
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
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                        
                        HStack {
                            Image("checkMark")
                            Text("할일")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(currentTodoList.indices, id: \.self) { index in
                            Text("\(currentTodoList[index].content)")
                        }
                        
                        Spacer()
                            .frame(height: 30)
                    }
                } // ScrollView
                
                VStack {
                    Spacer()
                    
                    HStack {
                        TextField("3월 14일 일정 추가", text: $content)
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

struct CalendarDayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDayDetailView(currentScheduleList: .constant([]), currentTodoList: .constant([]), index: 0)
            .frame(width: 330, height: 480)
    }
}
