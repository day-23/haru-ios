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
                HaruHeader {
                    // TODO: 검색 화면
                }

                // 날짜 레이아웃
                HStack(spacing: 0) {
                    Text("\(String(timeTableViewModel.currentYear))년")
                        .font(.pretendard(size: 28, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 34)
                    Text("\(timeTableViewModel.currentMonth)월")
                        .font(.pretendard(size: 28, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .padding(.leading, 10)
                    Image("toggle")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                        .rotationEffect(Angle(degrees: 90))
                        .scaleEffect(1.25)
                        .scaledToFit()
                        .padding(.leading, 10)

                    Spacer()

                    Text("\(Date().day)")
                        .font(.pretendard(size: 12, weight: .bold))
                        .foregroundColor(Color(0x2ca4ff))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            Circle()
                                .stroke(.gradation1, lineWidth: 2)
                        )
                        .padding(.trailing, 16)

                    Image(isScheduleView ? "time-table-todo" : "time-table-schedule")
                        .onTapGesture {
                            isScheduleView.toggle()
                        }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 18)

                if isScheduleView {
                    TimeTableScheduleView(
                        timeTableViewModel: _timeTableViewModel,
                        calendarViewModel: _calendarViewModel
                    )
                    .padding(.trailing, 15)
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
                                successAction: {}
                            ),
                            isSchModalVisible: $isModalVisible
                        )
                    } else {
                        TodoAddView(
                            viewModel: todoAddViewModel,
                            isModalVisible: $isModalVisible
                        )
                    }
                }
                .transition(.modal)
                .zIndex(2)
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
        .onAppear {
            timeTableViewModel.fetchScheduleList()
        }
    }
}
