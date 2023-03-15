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
                    
                    Button {
                        calendarVM.subMonthOffset()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Button {
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
                
                GeometryReader { proxy in
                    // TODO: 꾹 누르기만 해도 selectionSet에 아이템 담아주기

                    // MARK: - Gesture 분리를 위함

                    let longPress = LongPressGesture(minimumDuration: 0.3)
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
                    
                    Group {
                        LazyVGrid(columns: dateColumns, spacing: 0) {
                            ForEach(0 ..< calendarVM.dateList.count, id: \.self) { index in
                                VStack(spacing: 0) {
                                    CalendarDateItem(selectionSet: $calendarVM.selectionSet, value: calendarVM.dateList[index])
                                    
                                    CalendarScheduleItem(scheduleList: $calendarVM.scheduleList[index], date: calendarVM.dateList[index].day)
                                    Spacer()
                                }
                                .frame(width: proxy.size.width / 7, height: proxy.size.height / CGFloat(calendarVM.numberOfWeeks), alignment: .top)
                                .background(calendarVM.selectionSet.contains(calendarVM.dateList[index]) ? .cyan : .white)
                                .border(width: 0.5, edges: [.top], color: Color(0xd3d3d3))
                                .onTapGesture {
                                    calendarVM.selectedDate = calendarVM.dateList[index]
                                    isDayModalVisible = true
                                }
                            }
                        }
                    } // Group
                    .gesture(combined)
                } // GeometryReader
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
                    ScheduleFormView(repeatStart: calendarVM.selectionSet.sorted(by: <).first!.date, repeatEnd: calendarVM.selectionSet.sorted(by: <).last!.date)
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
