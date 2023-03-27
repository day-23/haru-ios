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
                            .font(.pretendard(size: 28, weight: .bold))
                        
                        Text(CalendarHelper.extraDate(calendarVM.monthOffest)[1])
                            .font(.pretendard(size: 28, weight: .bold))
                        
                        Button {
                            print("달력 보여주기")
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .tint(.gray1)
                    } // HStack
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button {
                            calendarVM.monthOffest = 0
                        } label: {
                            Text("\(Date().day)")
                                .font(.pretendard(size: 14, weight: .bold))
                                .padding(6)
                                .background(
                                    Circle()
                                        .stroke(.gradation1, lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                )
                        }
                        .tint(Color.gradientStart1)
                        
                        Button {
                            showingPopup = true
                        } label: {
                            Image("option-button")
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .popup(isPresented: $showingPopup, view: {
                            CalendarOptionView()
                                .environmentObject(calendarVM)
                                .background(Color.white)
                                .frame(width: UIScreen.main.bounds.maxX - 30, height: UIScreen.main.bounds.maxY - 240)
                                .cornerRadius(20)
                                .padding(.horizontal, 30)
                                .shadow(radius: 2.0)
                                .offset(x: 30)
                        }, customize: {
                            $0
                                .animation(.spring())
                                .closeOnTap(false)
                                .closeOnTapOutside(true)
                                .backgroundColor(.black.opacity(0.5))
                        })
                        .tint(.gray1)
                    }
                } // HStack
                .padding(.horizontal, 30)

                Group {
                    // Day View ...
                    HStack(spacing: 0) {
                        ForEach(calendarVM.dayList, id: \.self) { day in
                            Text(day)
                                .font(.pretendard(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                        }
                    } // HStack
                    
                    TabView(selection: $calendarVM.monthOffest) {
                        ForEach(-10 ... 10, id: \.self) { _ in
                            GeometryReader { proxy in
                                
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
                        } // ForEach
                    } // TabView
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                } // Group
                .padding(.horizontal, 20)
                Spacer().frame(height: 20)
            } // VStack

            // 일정 추가 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        calendarVM.selectionSet.insert(DateValue(day: Date().day, date: Date()))
                        isSchModalVisible = true
                    } label: {
                        Image("plus-button")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
            }
            .padding(20)
            .zIndex(2)
            
            
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
                CalendarDayView()
                    .environmentObject(calendarVM)
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
