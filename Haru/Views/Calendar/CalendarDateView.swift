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
    @State private var currentDate: DateValue = DateValue(day: Date().day, date: Date())
    
    // 드래그로 선택된 셀들 저장해놓는 리스트
    @State private var selectionSet: Set<DateValue> = []
    @State private var firstSelected: Bool = false
    
    // 날짜
    @State var dateList: [DateValue]
    
    // 요일
    var dayList: [String] {
        CalendarHelper.getDays(startOnSunday)
    }
    
    @State var firstIndex: Int = 0
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
                let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                
                GeometryReader { proxy in
                    let longPress = LongPressGesture(minimumDuration: 1.0)
                        .onChanged { isPressed in
                            if isPressed {
                                print("클릭 시작")
                            }
                        }
                        .onEnded { _ in
                            firstSelected = true
                        }
                    
                    let drag = DragGesture()
                        .onChanged { value in
                            selectItems(from: value, proxy.size.width / 7, proxy.size.height / 7)
                        }
                        .onEnded { value in
                            isSchModalVisible = true
                        }
                    
                    let combined = longPress.sequenced(before: drag)
                    
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(dateList) { item in
                            CalendarDateItem(selectionSet: $selectionSet, value: item)
                                .frame(width: proxy.size.width / 7, height: proxy.size.height / 7, alignment: .top)
                                .background(selectionSet.contains(item) ? .cyan : .white)
                                .onTapGesture {
                                    currentDate = item
                                    isDayModalVisible = true
                                }
                        }
                    }
                    .gesture(combined)
                }
            } // VStack
            
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
                        
                        Text("\(currentDate.date.month)월 \(currentDate.date.day)일")
                    }
                }
                .zIndex(2)
            }
            
            
        }
        .onChange(of: isSchModalVisible) { newValue in
            if !isSchModalVisible {
                selectionSet.removeAll()
                startIndex = 50
                lastIndex = -1
            }
        }
        .onChange(of: currentMonth) { newValue in
            dateList = CalendarHelper.extractDate(currentMonth, startOnSunday)
        }
    }
    
    func selectItems(from value: DragGesture.Value, _ cellWidth: Double, _ cellHeight: Double) {
        let index = Int(value.location.y / cellHeight) * 7 + Int(value.location.x / cellWidth)
        
        if firstSelected {
            firstIndex = index
            startIndex = index
            lastIndex = index
            firstSelected = false
        } else {
            if startIndex > index {
                for i in startIndex ... lastIndex {
                    selectionSet.remove(dateList[i])
                }
                
                lastIndex = firstIndex
                startIndex = index
            } else if lastIndex > index {
                for i in index ... lastIndex {
                    selectionSet.remove(dateList[i])
                }
                
                lastIndex = max(index, firstIndex)
            } else {
                lastIndex = index
            }
        }
        
        for i in startIndex ... lastIndex {
            selectionSet.insert(dateList[i])
        }
    }
}

struct CalendarDateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView(startOnSunday: .constant(true), dateList: CalendarHelper.extractDate(0, true))
    }
}
