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

    @State private var selection: Tab = .sns

    var body: some View {
        ZStack {
            // MARK: - Splash View

            if showSplash {
                SplashView(
                    isLoggedIn: $global.isLoggedIn
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
            } else {
                if global.isNetworkConnected {
                    if let me = global.user,
                       me.isMaliciousUser
                    {
                        Image("background-main-splash")
                            .edgesIgnoringSafeArea(.all)
                            .overlay {
                                Text("이용 제한된 계정입니다.")
                                    .font(.pretendard(size: 16, weight: .bold))
                                    .foregroundColor(Color(0x1DAFFF))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Color(0xFDFDFD, opacity: 0.5))
                                    .cornerRadius(10)
                                    .offset(y: UIScreen.main.bounds.height * 0.3)
                            }
                    } else if let me = global.user,
                              global.isLoggedIn,
                              !me.user.name.isEmpty,
                              !me.haruId.isEmpty
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
                                        let checkListViewModel: CheckListViewModel = .init(todoState: _todoState)
                                        
                                        TimeTableMainView(
                                            timeTableViewModel: .init(wrappedValue: timeTableViewModel),
                                            checkListViewModel: .init(wrappedValue: checkListViewModel),
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
                                            isLoggedIn: $global.isLoggedIn
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
                                                            global.isFaded = false
                                                        }
                                                }
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .onAppear {
                            if let morning = global.user?.morningAlarmTime {
                                AlarmHelper.createRegularNotification(regular: .morning, time: morning)
                            }
                            if let night = global.user?.nightAlarmTime {
                                AlarmHelper.createRegularNotification(regular: .evening, time: night)
                            }
                            UIDatePicker.appearance().minuteInterval = 5
                        }
                        .environmentObject(todoState)
                        .navigationViewStyle(.stack)
                    } else if let me = global.user,
                              global.isLoggedIn,
                              me.user.name.isEmpty,
                              me.haruId.isEmpty
                    {
                        // 회원 가입
                        SignUpView()
                    } else {
                        LoginView(
                            isLoggedIn: $global.isLoggedIn
                        )
                    }
                } else {
                    NetworkNotConnectedView()
                }
            }
        }
    }
}
