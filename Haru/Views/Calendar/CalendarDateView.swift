//
//  CalendarDateView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import SwiftUI

struct CalendarDateView: View {
    @State private var isSchModalVisible: Bool = false
    @State private var isDayModalVisible: Bool = false

    @ObservedObject var calendarVM: CalendarViewModel = .init()
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                // 최상단 바
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(CalendarHelper.extraDate(calendarVM.monthOffest)[0])
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text(CalendarHelper.extraDate(calendarVM.monthOffest)[1])
                            .font(.title.bold())
                    } // VStack
                    
                    Spacer(minLength: 0)
                    Toggle("일요일 부터 시작", isOn: $calendarVM.startOnSunday)
                    
//                    Button {
//                        calendarVM.setMonthOffset(0)
//                    } label: {
//                        Text("오늘로")
//                    }
                    
                    Button {
//                        calendarVM.setMonthOffset(calendarVM.monthOffest - 1)
                        calendarVM.subMonthOffset()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Button {
//                        calendarVM.setMonthOffset(calendarVM.monthOffest + 1)
                        calendarVM.addMonthOffset()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                } // HStack
                .padding(.horizontal)
                
                // Day View ...
                HStack(spacing: 0) {
                    ForEach(calendarVM.dayList, id: \.self) { day in
                        Text(day)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                } // HStack
                
                // Dates ...
                let dateColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                let scheduleCols = Array(repeating: GridItem(.flexible(), spacing: 0), count: 1)
                
                GeometryReader { proxy in
                    // TODO: 꾹 누르기만 해도 selectionSet에 아이템 담아주기

                    // MARK: - Gesture 분리를 위함

                    let longPress = LongPressGesture(minimumDuration: 0.5)
                        .onEnded { longPress in
                            calendarVM.firstSelected = true
                        }
                    
                    let drag = DragGesture()
                        .onChanged { value in
                            calendarVM.addSelectedItems(from: value, proxy.size.width / 7, proxy.size.height / CGFloat(calendarVM.numberOfWeeks))
                        }
                        .onEnded { value in
                            isSchModalVisible = true
                        }
                    
                    let combined = longPress.sequenced(before: drag)
                    
                    ZStack {
                        LazyVGrid(columns: dateColumns, spacing: 0) {
                            ForEach(calendarVM.dateList) { item in
                                CalendarDateItem(selectionSet: $calendarVM.selectionSet, value: item)
                                    .frame(width: proxy.size.width / 7, height: proxy.size.height / CGFloat(calendarVM.numberOfWeeks), alignment: .top)
                                    .background(calendarVM.selectionSet.contains(item) ? .cyan : .white)
                                    .border(width: 0.5, edges: [.top], color: Color(0xd3d3d3))
                                    .onTapGesture {
                                        calendarVM.selectedDate = item
                                        isDayModalVisible = true
                                    }
                            }
                        }
                        
                        LazyVGrid(columns: scheduleCols, spacing: 0) {
                            ForEach(Array(0 ..< calendarVM.numberOfWeeks), id: \.self) { value in
                                VStack {
                                    Spacer()
                                        .frame(height: 32)
                                    CalendarScheduleItem(widthSize: proxy.size.width, heightSize: proxy.size.height / CGFloat(calendarVM.numberOfWeeks) - 32, scheduleList: $calendarVM.scheduleList[value])
                                        .frame(width: proxy.size.width, height: proxy.size.height / CGFloat(calendarVM.numberOfWeeks) - 32, alignment: .top)
                                }
                            }
                        }
                        .frame(height: proxy.size.height, alignment: .top)
                    } // ZStack
                    .gesture(combined)
                }
            } // VStack
            
            // 일정 추가를 위한 모달창
            if isSchModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        isSchModalVisible = false
                    }
                
                Modal(isActive: $isSchModalVisible, ratio: 0.8) {
                    VStack {
                        List(Array(calendarVM.selectionSet)) { value in
                            Text("\(value.date)")
                        }
                    }
                }
                .zIndex(2)
            }
            
            // 선택된 날(하루)을 위한 모달창
            if isDayModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        isDayModalVisible = false
                    }
                
                Modal(isActive: $isDayModalVisible, ratio: 0.8) {
                    VStack(spacing: 20) {
                        Text("선택된 날을 위한 뷰")
                        
                        Text("\(calendarVM.selectedDate.date.month)월 \(calendarVM.selectedDate.date.day)일")
                    }
                }
                .zIndex(2)
            }
        }
        .onChange(of: isSchModalVisible) { _ in
            if !isSchModalVisible {
                calendarVM.selectionSet.removeAll()
            }
        }
        .onChange(of: calendarVM.startOnSunday) { newValue in
            calendarVM.setStartOnSunday(newValue)
        }
    }
}

struct CalendarDateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView()
    }
}
