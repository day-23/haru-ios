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
    
    @State private var showingPopup: Bool = false

    @EnvironmentObject var calendarVM: CalendarViewModel

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
                            showingPopup = true
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .sheet(isPresented: $showingPopup) {
                            CalendarOptionView()
                                .environmentObject(calendarVM)
                        }
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
                        
                        CalendarWeekView(
                            isDayModalVisible: $isDayModalVisible,
                            cellHeight: proxy.size.height / CGFloat(calendarVM.numberOfWeeks),
                            cellWidhth: proxy.size.width / 7
                        )
                        .environmentObject(calendarVM)
                        .gesture(combined)
                    } // GeometryReader
                } // Group
                .padding(.horizontal)
            } // VStack

            // 일정 추가 버튼
            Button {
                calendarVM.selectionSet.insert(DateValue(day: Date().day, date: Date()))
                isSchModalVisible = true
            } label: {
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
                        scheduleFormVM: ScheduleFormViewModel(calendarVM: calendarVM), isSchModalVisible: $isSchModalVisible
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
                            ForEach(calendarVM.selectedProdList.indices, id: \.self) { index in
                                Text(calendarVM.selectedProdList[index].content)
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
        .onChange(of: calendarVM.startOnSunday) { newValue in
            calendarVM.setStartOnSunday(newValue)
        }
    }
}

struct CalendarDateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView()
            .environmentObject(CalendarViewModel())
    }
}
