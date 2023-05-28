//
//  TimeTableMainView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct TimeTableMainView: View {
    // MARK: - Properties

    @StateObject var timeTableViewModel: TimeTableViewModel
    @StateObject var calendarViewModel: CalendarViewModel = .init()
    @StateObject var todoAddViewModel: TodoAddViewModel

    @State private var isScheduleView: Bool = true

    @State private var isModalVisible: Bool = false
    @State private var isPopupVisible: Bool = false

    @State private var isDateButtonClicked: Bool = false

    init(
        timeTableViewModel: StateObject<TimeTableViewModel>,
        todoAddViewModel: StateObject<TodoAddViewModel>
    ) {
        _timeTableViewModel = timeTableViewModel
        _todoAddViewModel = todoAddViewModel
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // 날짜 레이아웃
                HStack(spacing: 0) {
                    Text("\(String(timeTableViewModel.currentYear))년")
                        .font(.pretendard(size: 28, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 33)
                    Text("\(timeTableViewModel.currentMonth)월")
                        .font(.pretendard(size: 28, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 10)
                        .padding(.trailing, 6)

                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isDateButtonClicked.toggle()
                        }
                    } label: {
                        Image("toggle-datepicker")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                            .rotationEffect(
                                Angle(
                                    degrees: isDateButtonClicked
                                        ? 90
                                        : 0
                                )
                            )
                    }
                    .popover(
                        isPresented: $isDateButtonClicked,
                        arrowDirection: .up
                    ) {
                        DatePicker(
                            "",
                            selection: $timeTableViewModel.currentDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }

                    Spacer()

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
                    .padding(.trailing, 10)

                    Button {
                        timeTableViewModel.currentDate = .now
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
                            .padding(.trailing, 10)
                    }

                    Image(
                        isScheduleView
                            ? "time-table-todo"
                            : "time-table-schedule"
                    )
                    .resizable()
                    .frame(width: 28, height: 28)
                    .onTapGesture {
                        isScheduleView.toggle()
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 14)

                if isScheduleView {
                    TimeTableScheduleView(
                        timeTableViewModel: _timeTableViewModel,
                        calendarViewModel: _calendarViewModel,
                        isPopupVisible: $isPopupVisible
                    )
                    .padding(.trailing, 20)
                } else {
                    TimeTableTodoView(
                        todoAddViewModel: _todoAddViewModel,
                        timeTableViewModel: _timeTableViewModel
                    )
                }
            }

            if isModalVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            isModalVisible = false
                        }
                    }

                Modal(isActive: $isModalVisible, ratio: 0.9) {
                    if isScheduleView {
                        ScheduleFormView(
                            scheduleFormVM: ScheduleFormViewModel(
                                selectionSet: calendarViewModel.selectionSet,
                                categoryList: calendarViewModel.categoryList,
                                successAction: {
                                    timeTableViewModel.fetchScheduleList()
                                }
                            ),
                            isSchModalVisible: $isModalVisible
                        )
                    } else {
                        TodoAddView(
                            viewModel: todoAddViewModel,
                            isModalVisible: $isModalVisible
                        )
                        .onAppear {
                            todoAddViewModel.isSelectedEndDate = true
                        }
                    }
                }
                .transition(.modal)
                .zIndex(2)
            } else {
                if isPopupVisible {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .zIndex(1)
                            .onTapGesture {
                                isPopupVisible = false
                                Global.shared.isFaded = false
                            }

                        CalendarDayView(calendarViewModel: calendarViewModel)
                            .zIndex(2)
                    }
                } else {
                    Button {
                        withAnimation {
                            isModalVisible = true
                        }
                    } label: {
                        Image("add-button")
                            .shadow(radius: 10, x: 5, y: 0)
                            .padding(.trailing, 20)
                            .padding(.bottom, 10)
                    }
                }
            }
        }
        .onAppear {
            timeTableViewModel.fetchScheduleList()
        }
    }
}
