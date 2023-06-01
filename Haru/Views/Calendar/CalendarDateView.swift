//
//  CalendarDateView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import SwiftUI

struct CalendarDateView: View {
    @State private var isSchModalVisible: Bool = false
    @State private var isTodoModalVisible: Bool = false
    @State private var isDayModalVisible: Bool = false
    
    @State private var isOptionModalVisible: Bool = false
    
    @State var showAddButton: Bool = true
    @State var showSchButton: Bool = false
    @State var showTodoButton: Bool = false

    @StateObject var calendarVM: CalendarViewModel
    @StateObject var addViewModel: TodoAddViewModel
    
    @State var width = UIScreen.main.bounds.width - 50
    @State var x = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Text("\(CalendarHelper.extraDate(self.calendarVM.monthOffest)[0])년")
                                .font(.pretendard(size: 28, weight: .bold))
                                .padding(.trailing, 4)
                            
                            Text("\(CalendarHelper.extraDate(self.calendarVM.monthOffest)[1])월")
                                .font(.pretendard(size: 28, weight: .bold))
                            
                            Image("toggle-datepicker")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(0x191919))
                                .frame(width: 28, height: 28)
                        } // HStack
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
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
                            
                            Button {
                                self.calendarVM.monthOffest = 0
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
                                        self.isOptionModalVisible = true
                                        Global.shared.isFaded = true
                                        self.x = 0
                                    }
                                }
                        }
                    } // HStack
                    .padding(.leading, 33)
                    .padding(.trailing, 20)
                    
                    Group {
                        // Day View ...
                        HStack(spacing: 0) {
                            ForEach(self.calendarVM.dayList.indices, id: \.self) { index in
                                Text(self.calendarVM.dayList[index])
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(
                                        index == 0 ?
                                            Color(0xf71e58) :
                                            index == 6 ?
                                            Color(0x1dafff)
                                            :
                                            Color(0x646464)
                                    )
                            }
                        } // HStack
                        .padding(.top, 14)
                        .padding(.bottom, 3)
                        
                        TabView(selection: self.$calendarVM.monthOffest) {
                            ForEach(-10 ... 100, id: \.self) { _ in
                                GeometryReader { proxy in
                                    
                                    let longPress = LongPressGesture(minimumDuration: 0.3)
                                        .onEnded { longPress in
                                            self.calendarVM.firstSelected = true
                                        }
                                    
                                    let drag = DragGesture()
                                        .onChanged { value in
                                            self.calendarVM.addSelectedItems(
                                                from: value,
                                                proxy.size.width / 7,
                                                proxy.size.height / CGFloat(self.calendarVM.numberOfWeeks)
                                            )
                                        }
                                        .onEnded { value in
                                            self.isSchModalVisible = true
                                        }
                                    
                                    let combined = longPress.sequenced(before: drag)
                                    
                                    CalendarWeekView(
                                        calendarVM: self.calendarVM,
                                        isDayModalVisible: self.$isDayModalVisible,
                                        cellHeight: proxy.size.height / CGFloat(self.calendarVM.numberOfWeeks),
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
                self.calendarVM.dayList = CalendarHelper.getDays(self.calendarVM.startOnSunday)
                self.calendarVM.getCategoryList()
                self.calendarVM.getCurDateList(self.calendarVM.monthOffest, self.calendarVM.startOnSunday)
            }

            // 추가 버튼
            if !self.isDayModalVisible, !self.isOptionModalVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if self.showTodoButton {
                            Button {
                                self.isTodoModalVisible = true
                                self.addViewModel.mode = .add
                            } label: {
                                Image("schedule-button")
                                    .resizable()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                                    .shadow(radius: 10, x: 5, y: 0)
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        
                        if self.showSchButton {
                            Button {
                                self.calendarVM.selectionSet.insert(DateValue(day: Date().day, date: Date()))
                                self.isSchModalVisible = true
                            } label: {
                                Image("schedule-button")
                                    .resizable()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                                    .shadow(radius: 10, x: 5, y: 0)
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        
                        if self.showAddButton {
                            Button {
                                withAnimation {
                                    self.showAddMenu()
                                }
                            } label: {
                                Image("add-button")
                                    .resizable()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                                    .shadow(radius: 10, x: 5, y: 0)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .zIndex(2)
            }
            
            // 일정 추가를 위한 모달창
            if self.isSchModalVisible {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        self.isSchModalVisible = false
                    }

                Modal(isActive: self.$isSchModalVisible, ratio: 0.9) {
                    ScheduleFormView(
                        scheduleFormVM: ScheduleFormViewModel(
                            selectionSet: self.calendarVM.selectionSet,
                            categoryList: self.calendarVM.categoryList
                        ) {
                            self.calendarVM.getCurMonthSchList(self.calendarVM.dateList)
                            self.calendarVM.getRefreshProductivityList()
                        },
                        isSchModalVisible: self.$isSchModalVisible
                    )
                }
                .transition(.modal)
                .zIndex(2)
            }
            
            // 할일 추가를 위한 모달창
            if self.isTodoModalVisible {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        self.isTodoModalVisible = false
                    }

                Modal(isActive: self.$isTodoModalVisible, ratio: 0.9) {
                    TodoAddView(
                        viewModel: self.addViewModel,
                        isModalVisible: self.$isTodoModalVisible
                    )
                }
                .transition(.modal)
                .zIndex(2)
            }

            // 선택된 날(하루)을 위한 모달창
            if self.isDayModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.isDayModalVisible = false
                            Global.shared.isFaded = false
                        }
                    }
                
                CalendarDayView(calendarViewModel: self.calendarVM)
                    .zIndex(2)
            }
            
            // 설정을 위한 슬라이드 메뉴
            Group {
                if self.isOptionModalVisible {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation {
                                self.x = UIScreen.main.bounds.width
                                self.isOptionModalVisible = false
                                Global.shared.isFaded = false
                            }
                        }
                }
                SlideOptionView(calendarVM: self.calendarVM)
                    .shadow(color: .black.opacity(self.x != 0 ? 0.1 : 0), radius: 5)
                    .offset(x: self.x)
                    .gesture(DragGesture().onChanged { value in
                        withAnimation {
                            if value.translation.width > 0 {
                                self.x = value.translation.width
                            }
                        }
                    }.onEnded { value in
                        withAnimation {
                            if self.x > self.width / 3 {
                                self.x = UIScreen.main.bounds.width
                                self.isOptionModalVisible = false
                                Global.shared.isFaded = false
                            } else {
                                self.x = 0
                            }
                        }
                    })
                    .zIndex(2)
            }
        } // ZStack
        .onTapGesture {
            withAnimation {
                self.hideAddMenu()
            }
        }
        .onChange(of: self.isSchModalVisible) { _ in
            if !self.isSchModalVisible {
                self.calendarVM.selectionSet.removeAll()
            }
        }
        .onChange(of: self.calendarVM.startOnSunday) { newValue in
            self.calendarVM.setStartOnSunday(newValue)
        }
        .onChange(of: self.isOptionModalVisible) { newValue in
            if newValue == false {
                self.calendarVM.setAllCategoryList()
            }
        }
    }
    
    func showAddMenu() {
        self.showAddButton = false
        self.showSchButton = true
        self.showTodoButton = true
    }
    
    func hideAddMenu() {
        self.showTodoButton = false
        self.showSchButton = false
        self.showAddButton = true
    }
}

// struct CalendarDateView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarDateView(calendarVM: CalendarViewModel())
//    }
// }
