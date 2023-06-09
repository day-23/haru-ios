//
//  TimeTableMainView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct TimeTableMainView: View {
    init(
        timeTableViewModel: StateObject<TimeTableViewModel>,
        checkListViewModel: StateObject<CheckListViewModel>,
        todoAddViewModel: StateObject<TodoAddViewModel>
    ) {
        _timeTableViewModel = timeTableViewModel
        _checkListViewModel = checkListViewModel
        _todoAddViewModel = todoAddViewModel
    }

    @EnvironmentObject var todoState: TodoState

    @StateObject var timeTableViewModel: TimeTableViewModel
    @StateObject var checkListViewModel: CheckListViewModel

    @StateObject var calendarViewModel: CalendarViewModel = .init()
    @StateObject var todoAddViewModel: TodoAddViewModel

    @State private var isScheduleView: Bool = true
    @State private var isModalVisible: Bool = false
    @State private var isDateButtonClicked: Bool = false

    var body: some View {
        let isPopupVisible: Binding<Bool> = .init {
            Global.shared.isFaded
        } set: { Global.shared.isFaded = $0 }

        return ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // 날짜 레이아웃
                HStack(spacing: 0) {
                    Text("\(String(self.timeTableViewModel.currentYear))년")
                        .font(.pretendard(size: 28, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 33)
                    Text("\(self.timeTableViewModel.currentMonth)월")
                        .font(.pretendard(size: 28, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 10)
                        .padding(.trailing, 6)

                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.isDateButtonClicked.toggle()
                        }
                    } label: {
                        Image("header-date-picker")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                            .rotationEffect(
                                Angle(
                                    degrees: self.isDateButtonClicked
                                        ? 90
                                        : 0
                                )
                            )
                    }
                    .popover(
                        isPresented: self.$isDateButtonClicked,
                        arrowDirection: .up
                    ) {
                        DatePicker(
                            "",
                            selection: self.$timeTableViewModel.currentDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }

                    Spacer()

                    NavigationLink {
                        // TODO: 검색 뷰 만들어지면 넣어주기
                        ProductivitySearchView(
                            calendarVM: self.calendarViewModel,
                            todoAddViewModel: self.todoAddViewModel,
                            checkListVM: self.checkListViewModel
                        )
                    } label: {
                        Image("search")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                    .padding(.trailing, 10)

                    Button {
                        self.timeTableViewModel.currentDate = .now
                    } label: {
                        Image("time-table-date-circle")
                            .overlay {
                                Text("\(Date().day)")
                                    .font(.pretendard(size: 14, weight: .bold))
                                    .foregroundColor(Color(0x2ca4ff))
                            }
                            .padding(.trailing, 10)
                    }

                    Image(
                        self.isScheduleView
                            ? "time-table-todo"
                            : "time-table-schedule"
                    )
                    .resizable()
                    .frame(width: 28, height: 28)
                    .onTapGesture {
                        self.isScheduleView.toggle()
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 14)

                if self.isScheduleView {
                    TimeTableScheduleView(
                        timeTableViewModel: _timeTableViewModel,
                        calendarViewModel: _calendarViewModel,
                        isPopupVisible: isPopupVisible
                    )
                    .padding(.trailing, 20)
                } else {
                    TimeTableTodoView(
                        todoAddViewModel: _todoAddViewModel,
                        timeTableViewModel: _timeTableViewModel
                    )
                }

                Spacer()
            }

            if self.isModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            self.isModalVisible = false
                        }
                    }

                Modal(isActive: self.$isModalVisible, ratio: 0.9) {
                    if self.isScheduleView {
                        ScheduleFormView(
                            scheduleFormVM: ScheduleFormViewModel(
                                selectionSet: self.calendarViewModel.selectionSet,
                                categoryList: self.calendarViewModel.categoryList,
                                successAction: {
                                    self.timeTableViewModel.fetchScheduleList()
                                }
                            ),
                            isSchModalVisible: self.$isModalVisible
                        )
                    } else {
                        TodoAddView(
                            viewModel: self.todoAddViewModel,
                            isModalVisible: self.$isModalVisible
                        )
                        .onAppear {
                            self.todoAddViewModel.isSelectedEndDate = true
                        }
                    }
                }
                .transition(.modal)
                .zIndex(2)
            } else {
                if isPopupVisible.wrappedValue {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .zIndex(1)
                            .onTapGesture {
                                isPopupVisible.wrappedValue = false
                            }

                        CalendarDayView(calendarViewModel: self.calendarViewModel)
                            .zIndex(2)
                    }
                } else {
                    Button {
                        withAnimation {
                            self.isModalVisible = true
                        }
                    } label: {
                        Image("add-button")
                            .padding(.trailing, 20)
                            .padding(.bottom, 10)
                    }
                }
            }
        }
        .onAppear {
            self.timeTableViewModel.fetchScheduleList()
        }
    }
}
