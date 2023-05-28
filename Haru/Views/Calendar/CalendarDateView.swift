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
    
    @State var width = UIScreen.main.bounds.width - 50
    @State var x = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader {
                    Color.white
                } item: {
                    NavigationLink {
                        // TODO: 검색 뷰 만들어지면 넣어주기
                        Text("검색")
                    } label: {
                        Image("magnifyingglass")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                }
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Text("\(CalendarHelper.extraDate(calendarVM.monthOffest)[0])년")
                                .font(.pretendard(size: 28, weight: .bold))
                                .padding(.trailing, 4)
                            
                            Text("\(CalendarHelper.extraDate(calendarVM.monthOffest)[1])월")
                                .font(.pretendard(size: 28, weight: .bold))
                            
                            Image("toggle-datepicker")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(0x191919))
                                .frame(width: 28, height: 28)
                        } // HStack
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            Button {
                                calendarVM.monthOffest = 0
                            } label: {
                                Text("\(Date().day)")
                                    .font(.pretendard(size: 12, weight: .bold))
                                    .foregroundColor(Color(0x2ca4ff))
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 6)
                                    .background(
                                        Circle()
                                            .stroke(LinearGradient(colors: [Color(0x9fa9ff), Color(0x15afff)],
                                                                   startPoint: .topLeading,
                                                                   endPoint: .bottomTrailing),
                                                    lineWidth: 2)
                                    )
                            }
                            .tint(Color.gradientStart1)
                            
                            Image("option-button")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(0x191919))
                                .frame(width: 28, height: 28)
                                .onTapGesture {
                                    withAnimation {
                                        isOptionModalVisible = true
                                        Global.shared.isFaded = true
                                        x = 0
                                    }
                                }
                        }
                    } // HStack
                    .padding(.leading, 33)
                    .padding(.trailing, 20)
                    
                    Group {
                        // Day View ...
                        HStack(spacing: 0) {
                            ForEach(calendarVM.dayList, id: \.self) { day in
                                Text(day)
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .frame(maxWidth: .infinity)
                            }
                        } // HStack
                        .padding(.top, 14)
                        .padding(.bottom, 3)
                        
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
                        withAnimation {
                            isDayModalVisible = false
                            Global.shared.isFaded = false
                        }
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
                                Global.shared.isFaded = false
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
                                Global.shared.isFaded = false
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
        .onChange(of: isOptionModalVisible) { newValue in
            if newValue == false {
                calendarVM.setAllCategoryList()
            }
        }
    }
}

struct CalendarDateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView(calendarVM: CalendarViewModel())
    }
}
