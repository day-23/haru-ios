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

    @ObservedObject var calendarVM: CalendarViewModel
    
    @State private var selectedSchedule: [Schedule] = []

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                // 최상단 바
                HStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Text("\(CalendarHelper.extraDate(calendarVM.monthOffest)[0])년")
                            .font(Font.custom(Constants.Bold, size: 28))
                        
                        Text(CalendarHelper.extraDate(calendarVM.monthOffest)[1])
                            .font(Font.custom(Constants.Bold, size: 28))
                        
                        Button {
                            print("달력 보여주기")
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .tint(.gray1)
                    } // HStack
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button {
                            calendarVM.setMonthOffset(0)
                        } label: {
                            Text("\(Date().day)")
                                .font(Font.custom(Constants.Bold, size: 12))
                                .padding(8)
                                .background(
                                    Circle()
                                        .stroke(.gradation1, lineWidth: 2)
                                )
                        }
                        
                        Button {
                            print("option")
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .tint(.gray1)
                    }
                } // HStack
                .padding(.horizontal, 20)

                Group {
                    // Day View ...
                    HStack(spacing: 0) {
                        ForEach(calendarVM.dayList, id: \.self) { day in
                            Text(day)
                                .font(Font.custom(Constants.Regular, size: 14))
                                .frame(maxWidth: .infinity)
                        }
                    } // HStack
                    
                    // Dates ...
                    let dateColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                    
                    GeometryReader { proxy in
                        
                        // MARK: - Gesture 분리를 위함
                        
                        let longPress = LongPressGesture(minimumDuration: 0.3)
                            .onEnded { longPress in
                                calendarVM.firstSelected = true
                            }
                        
                        let drag = DragGesture()
                            .onChanged { value in
                                calendarVM.addSelectedItems(
                                    from: value,
                                    proxy.size.width / 7,
                                    proxy.size.height / CGFloat(calendarVM.numberOfWeeks)
                                )
                            }
                            .onEnded { value in
                                isSchModalVisible = true
                            }
                        
                        let combined = longPress.sequenced(before: drag)
                        
                        Group {
                            LazyVGrid(columns: dateColumns, spacing: 0) {
                                ForEach(0 ..< calendarVM.dateList.count, id: \.self) { index in
                                    VStack(spacing: 0) {
                                        CalendarDateItem(
                                            selectionSet: $calendarVM.selectionSet,
                                            value: calendarVM.dateList[index]
                                        )
                                        
                                        CalendarScheduleItem(
                                            scheduleList: $calendarVM.scheduleList[index],
                                            date: calendarVM.dateList[index].day
                                        )
                                        Spacer()
                                    }
                                    .frame(
                                        width: proxy.size.width / 7,
                                        height: proxy.size.height / CGFloat(calendarVM.numberOfWeeks),
                                        alignment: .top
                                    )
                                    .background(calendarVM.selectionSet
                                        .contains(calendarVM.dateList[index]) ? .cyan : .white)
                                    .border(width: 0.5, edges: [.top], color: Color(0xD3D3D3))
                                    .onTapGesture {
                                        calendarVM.selectedDate = calendarVM.dateList[index]
                                        selectedSchedule = calendarVM.getSelectedScheduleList(index)
                                        isDayModalVisible = true
                                    }
                                }
                            }
                        } // Group
                        .gesture(combined)
                    } // GeometryReader
                }
                .padding(.horizontal)
            } // VStack

            // 일정 추가 버튼
            Button {} label: {
                Image("plusButton")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .position(x: UIScreen.main.bounds.maxX - 40, y: UIScreen.main.bounds.maxY - 170)
            
            // 일정 추가를 위한 모달창
            if isSchModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        isSchModalVisible = false
                    }

                Modal(isActive: $isSchModalVisible, ratio: 0.9) {
                    ScheduleFormView(
                        scheduleFormVM: ScheduleFormViewModel(calendarVM: calendarVM)
                    )
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

                Modal(isActive: $isDayModalVisible, ratio: 0.9) {
                    VStack(spacing: 20) {
                        Text("선택된 날을 위한 뷰")

                        Text(
                            "\(calendarVM.selectedDate.date.month)월 \(calendarVM.selectedDate.date.day)일"
                        )
                        
                        List {
                            ForEach(selectedSchedule) { sch in
                                Text(sch.content)
                            }
                        }
                    }
                }
                .zIndex(2)
            }
        } // ZStack
        .onChange(of: isSchModalVisible) { _ in
            if !isSchModalVisible {
                calendarVM.selectionSet.removeAll()
            }
        }
        .onChange(of: isDayModalVisible) { _ in
            if !isDayModalVisible {
                selectedSchedule.removeAll()
            }
        }
        .onChange(of: calendarVM.startOnSunday) { newValue in
            calendarVM.setStartOnSunday(newValue)
        }
    }
}

struct CalendarDateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView(calendarVM: CalendarViewModel())
    }
}
