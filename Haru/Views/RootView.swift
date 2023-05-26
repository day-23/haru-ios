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

    @State private var selection: Int = 0

    var body: some View {
        Group {
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
                                VStack {
                                    if selection == 0 {
                                        // MARK: - SNS View

                                        SNSView()
                                    } else if selection == 1 {
                                        // MARK: - CheckList View

                                        Group {
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
                                        }
                                    } else if selection == 2 {
                                        // MARK: - Calendar View

                                        CalendarMainView()
                                    } else if selection == 3 {
                                        // MARK: - TimeTable View

                                        Group {
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
                                        }
                                    } else if selection == 4 {
                                        // MARK: - Setting View

                                        MyView(
                                            isLoggedIn: $isLoggedIn
                                        )
                                    }

                                    if global.isTabViewActive {
                                        Spacer()
                                        CustomTabView(selection: $selection)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            UITabBar.appearance().backgroundColor = .white
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
}
