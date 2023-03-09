//
//  CalendarDateView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import SwiftUI

struct CalendarDateView: View {
    @Binding var startOnSunday: Bool
    @State private var isSchModalVisible: Bool = false
    @State private var isDayModalVisible: Bool = false
    
    // Month update on arrow button clicks ...
    @State private var currentMonth: Int = 0 // 0(now) 1(next) -1(prev) ...
    @State private var selectedDate: DateValue = .init(day: Date().day, date: Date())
    
    // 드래그로 선택된 셀들 저장해놓는 리스트
    @State private var selectionSet: Set<DateValue> = []
    @State private var firstSelected: Bool = false
    
    // 날짜
    @State var dateList: [DateValue]
    @State var numberOfWeeks: Int
    
    // 요일
    var dayList: [String] {
        CalendarHelper.getDays(startOnSunday)
    }
    
    // 스케줄
    @ObservedObject var calendarVM: CalendarViewModel
    
    @State var initIndex: Int = 0
    @State var startIndex: Int = 0
    @State var lastIndex: Int = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                // 최상단 바
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(CalendarHelper.extraDate(currentMonth)[0])
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text(CalendarHelper.extraDate(currentMonth)[1])
                            .font(.title.bold())
                    } // VStack
                    
                    Spacer(minLength: 0)
                    Toggle("일요일 부터 시작", isOn: $startOnSunday)
                    
                    Button {
                        currentMonth -= 1

                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Button {
                        currentMonth += 1
                        
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                } // HStack
                .padding(.horizontal)
                
                // Day View ...
                HStack(spacing: 0) {
                    ForEach(dayList, id: \.self) { day in
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
                            firstSelected = true
                        }
                    
                    let drag = DragGesture()
                        .onChanged { value in
                            selectItems(from: value, proxy.size.width / 7, proxy.size.height / CGFloat(numberOfWeeks))
                        }
                        .onEnded { value in
                            isSchModalVisible = true
                        }
                    
                    let combined = longPress.sequenced(before: drag)
                    
                    ZStack {
                        LazyVGrid(columns: dateColumns, spacing: 0) {
                            ForEach(dateList) { item in
                                CalendarDateItem(selectionSet: $selectionSet, value: item)
                                    .frame(width: proxy.size.width / 7, height: proxy.size.height / CGFloat(numberOfWeeks), alignment: .top)
                                    .background(selectionSet.contains(item) ? .cyan : .white)
                                    .border(width: 0.5, edges: [.top], color: Color(0xd3d3d3))
                                    .onTapGesture {
                                        selectedDate = item
                                        isDayModalVisible = true
                                    }
                            }
                        }
                        .gesture(combined)
                        
                        LazyVGrid(columns: scheduleCols, spacing: 0) {
                            ForEach(Array(0 ..< numberOfWeeks), id: \.self) { value in
                                VStack {
                                    Spacer()
                                        .frame(height: 32)
                                    CalendarScheduleItem(widthSize: proxy.size.width, heightSize: proxy.size.height / CGFloat(numberOfWeeks), scheduleList: $calendarVM.scheduleList[value])
                                        .frame(height: (proxy.size.height / CGFloat(numberOfWeeks)) - 32, alignment: .top)
                                }
                                .frame(height: proxy.size.height / CGFloat(numberOfWeeks), alignment: .top)
                            }
                        }
                        .frame(height: proxy.size.height, alignment: .top)
                    } // ZStack
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
                        List(Array(selectionSet)) { value in
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
                        
                        Text("\(selectedDate.date.month)월 \(selectedDate.date.day)일")
                    }
                }
                .zIndex(2)
            }
        }
        .onChange(of: isSchModalVisible) { _ in
            if !isSchModalVisible {
                selectionSet.removeAll()
            }
        }
        .onChange(of: currentMonth) { _ in
            dateList = CalendarHelper.extractDate(currentMonth, startOnSunday)
            numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)
            calendarVM.getCurMonthSchList(currentMonth, dateList)
        }
        .onChange(of: startOnSunday) { _ in
            dateList = CalendarHelper.extractDate(currentMonth, startOnSunday)
            numberOfWeeks = CalendarHelper.numberOfWeeksInMonth(dateList.count)
            calendarVM.getCurMonthSchList(currentMonth, dateList)
        }
    }
    
    func selectItems(from value: DragGesture.Value, _ cellWidth: Double, _ cellHeight: Double) {
        let index = Int(value.location.y / cellHeight) * 7 + Int(value.location.x / cellWidth)
        var isRangeChanged = (true, true)
        
        if firstSelected {
            initIndex = index
            startIndex = index
            lastIndex = index
            firstSelected = false
            
            selectionSet.insert(dateList[initIndex])
        }
        
        if startIndex > index {
            startIndex = index
        } else if startIndex < index {
            for i in startIndex ..< min(initIndex, index) {
                selectionSet.remove(dateList[i])
            }
            startIndex = min(initIndex, index)
        } else {
            isRangeChanged.0 = false
        }
        
        if lastIndex < index {
            lastIndex = index
        } else if lastIndex > index {
            var i = max(initIndex, index) + 1
            while i <= lastIndex {
                selectionSet.remove(dateList[i])
                i += 1
            }
            lastIndex = max(initIndex, index)
        } else {
            isRangeChanged.1 = false
        }
        
        if isRangeChanged.0, isRangeChanged.1 {
            for i in startIndex ... lastIndex {
                selectionSet.insert(dateList[i])
            }
        }
    }
}

struct CalendarDateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView(startOnSunday: .constant(true), dateList: CalendarHelper.extractDate(0, true), numberOfWeeks: CalendarHelper.numberOfWeeksInMonth(CalendarHelper.extractDate(0, true).count), calendarVM: CalendarViewModel(dateList: CalendarHelper.extractDate(0, true)))
    }
}
