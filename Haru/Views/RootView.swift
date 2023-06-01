//
//  RootView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/05.
//

import Foundation
import SwiftUI

struct RootView: View {
    @EnvironmentObject var global: Global
    @StateObject private var todoState: TodoState = .init()
    @State private var showSplash: Bool = true
    @State private var isLoggedIn: Bool = false

    @State private var selection: Tab = .sns

    var body: some View {
        ZStack {
            // MARK: - Splash View

            if showSplash {
                SplashView(
                    isLoggedIn: $isLoggedIn
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
            } else {
                if let me = global.user,
                   isLoggedIn,
                   !me.user.name.isEmpty
                {
                    NavigationView {
                        ZStack {
                            VStack(spacing: 0) {
                                if selection == .sns {
                                    // MARK: - SNS View

                                    SNSView()
                                } else if selection == .todo {
                                    // MARK: - CheckList View

                                    let checkListViewModel: CheckListViewModel = .init(todoState: _todoState)
                                    let todoAddViewModel: TodoAddViewModel = .init(todoState: todoState) { id in
                                        checkListViewModel.selectedTag = nil
                                        checkListViewModel.justAddedTodoId = id
                                        checkListViewModel.fetchTags()
                                        checkListViewModel.fetchTodoList()
                                    } updateAction: { id in
                                        checkListViewModel.justAddedTodoId = id
                                        checkListViewModel.fetchTodoList()
                                        checkListViewModel.fetchTags()
                                    }

                                    CheckListView(
                                        viewModel: checkListViewModel,
                                        addViewModel: todoAddViewModel
                                    )
                                } else if selection == .calendar {
                                    // MARK: - Calendar View

                                    let checkListViewModel: CheckListViewModel = .init(todoState: _todoState)
                                    let calendarViewModel: CalendarViewModel = .init()
                                    let todoAddViewModel: TodoAddViewModel = .init(todoState: todoState) { id in
                                        calendarViewModel.getCurMonthSchList(calendarViewModel.dateList)

                                        checkListViewModel.selectedTag = nil
                                        checkListViewModel.justAddedTodoId = id
                                        checkListViewModel.fetchTags()
                                        checkListViewModel.fetchTodoList()
                                    } updateAction: { id in
                                        checkListViewModel.justAddedTodoId = id
                                        checkListViewModel.fetchTodoList()
                                        checkListViewModel.fetchTags()
                                    }

                                    CalendarMainView(
                                        calendarVM: calendarViewModel,
                                        addViewModel: todoAddViewModel
                                    )
                                } else if selection == .timetable {
                                    // MARK: - TimeTable View

                                    let timeTableViewModel: TimeTableViewModel = .init()

                                    TimeTableMainView(
                                        timeTableViewModel: .init(wrappedValue: timeTableViewModel),
                                        todoAddViewModel: .init(
                                            wrappedValue: TodoAddViewModel(
                                                todoState: todoState,
                                                addAction: { _ in
                                                    timeTableViewModel.fetchTodoList()
                                                },
                                                updateAction: { _ in
                                                    timeTableViewModel.fetchTodoList()
                                                }
                                            ))
                                    )
                                } else if selection == .my {
                                    // MARK: - Setting View

                                    MyView(
                                        isLoggedIn: $isLoggedIn
                                    )
                                }

                                if global.isTabViewActive {
                                    Spacer()
                                        .frame(height: .zero)

                                    CustomTabView(selection: $selection)
                                        .overlay {
                                            if global.isFaded {
                                                Color.black.opacity(0.4)
                                                    .edgesIgnoringSafeArea(.all)
                                                    .onTapGesture {
                                                        withAnimation {
                                                            global.isFaded = false
                                                        }
                                                    }
                                            }
                                        }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
                    .environmentObject(todoState)
                    .navigationViewStyle(.stack)
                } else if let me = global.user,
                          isLoggedIn,
                          me.user.name.isEmpty
                {
                    // 회원 가입
                    SignUpView()
                } else {
                    LoginView(
                        isLoggedIn: $isLoggedIn
                    )
                }
            }
        }
    }
}
