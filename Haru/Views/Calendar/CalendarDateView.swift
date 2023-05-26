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
    
    @State private var isOptionModalVisible: Bool = false

    @StateObject var calendarVM: CalendarViewModel
    
    @State var width = UIScreen.main.bounds.width - 33
    @State var x = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader {
                    // TODO: 검색 뷰 만들어지면 넣어주기
                    Text("검색")
                }
                VStack(spacing: 10) {
                    HStack(spacing: 15) {
                        HStack(spacing: 10) {
                            Text("\(CalendarHelper.extraDate(calendarVM.monthOffest)[0])년")
                                .font(.pretendard(size: 28, weight: .bold))
                            
                            Text("\(CalendarHelper.extraDate(calendarVM.monthOffest)[1])월")
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
                                withAnimation {
                                    isOptionModalVisible = true
                                    x = 0
                                }
                            } label: {
                                Image("option-button")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                            .tint(.gray1)
                        }
                    } // HStack
                    .padding(.leading, 34)
                    .padding(.trailing, 20)
                    
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
                            ForEach(-10 ... 100, id: \.self) { _ in
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
                                        calendarVM: calendarVM,
                                        isDayModalVisible: $isDayModalVisible,
                                        cellHeight: proxy.size.height / CGFloat(calendarVM.numberOfWeeks),
                                        cellWidth: proxy.size.width / 7
                                    )
                                    .gesture(combined)
                                } // GeometryReader
                            } // ForEach
                        } // TabView
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    } // Group
                    .padding(.horizontal, 20)
                    Spacer().frame(height: 20)
                } // VStack
            }
            .onAppear {
                calendarVM.dayList = CalendarHelper.getDays(calendarVM.startOnSunday)
                calendarVM.getCategoryList()
                calendarVM.getCurDateList(calendarVM.monthOffest, calendarVM.startOnSunday)
            }

            // 일정 추가 버튼
            if !isDayModalVisible, !isOptionModalVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            calendarVM.selectionSet.insert(DateValue(day: Date().day, date: Date()))
                            isSchModalVisible = true
                        } label: {
                            Image("add-button")
                                .resizable()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                                .shadow(radius: 10, x: 5, y: 0)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .zIndex(2)
            }
            
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
                        scheduleFormVM: ScheduleFormViewModel(
                            selectionSet: calendarVM.selectionSet,
                            categoryList: calendarVM.categoryList
                        ) {
                            calendarVM.getCurMonthSchList(calendarVM.dateList)
                            calendarVM.getRefreshProductivityList()
                        },
                        isSchModalVisible: $isSchModalVisible
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
                CalendarDayView(calendarViewModel: calendarVM)
                    .zIndex(2)
            }
            
            // 설정을 위한 슬라이드 메뉴
            Group {
                if isOptionModalVisible {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation {
                                x = UIScreen.main.bounds.width
                                isOptionModalVisible = false
                            }
                        }
                }
                SlideOptionView(calendarVM: calendarVM)
                    .shadow(color: .black.opacity(x != 0 ? 0.1 : 0), radius: 5)
                    .offset(x: x)
                    .gesture(DragGesture().onChanged { value in
                        withAnimation {
                            if value.translation.width > 0 {
                                x = value.translation.width
                            }
                        }
                    }.onEnded { value in
                        withAnimation {
                            if x > width / 3 {
                                x = UIScreen.main.bounds.width
                                isOptionModalVisible = false
                            } else {
                                x = 0
                            }
                        }
                    })
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
        CalendarDateView(calendarVM: CalendarViewModel())
    }
}
