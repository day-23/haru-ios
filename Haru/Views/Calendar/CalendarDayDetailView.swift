//
//  CalendarDayDetailView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI

struct CalendarDayDetailView: View {
    @State private var content: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("14일 화요일")
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
                        
                        ForEach(0 ... 5, id: \.self) { index in
                            HStack(spacing: 20) {
                                Circle()
                                    .fill(Color.random)
                                    .frame(width: 20, height: 20)
                                VStack(alignment: .leading) {
                                    Text("일정\(index)")
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
        CalendarDayDetailView()
            .frame(width: 330, height: 480)
    }
}
