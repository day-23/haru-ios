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
                        TabView {
                            // MARK: - SNS View

                            NavigationView {
                                SNSView()
                            }
                            .tabItem {
                                Image(systemName: "paperplane")
                                Text("SNS")
                            }
                            .tag("SNS")
                            .navigationViewStyle(.stack)

                            // MARK: - CheckList View

                            NavigationView {
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
                            .tabItem {
                                Image(systemName: "checklist")
                                Text("Check-List")
                            }
                            .tag("Check-List")
                            .navigationViewStyle(.stack)

                            // MARK: - Calendar View

                            NavigationView {
                                CalendarMainView()
                            }
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("Calendar")
                            }
                            .tag("Calendar")
                            .navigationViewStyle(.stack)

                            // MARK: - TimeTable View

                            NavigationView {
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
                            .tabItem {
                                Image(systemName: "calendar.day.timeline.left")
                                Text("Time-Table")
                            }
                            .tag("Time-Table")
                            .navigationViewStyle(.stack)

                            // MARK: - Setting View

                            NavigationView {
                                MyView(
                                    isLoggedIn: $isLoggedIn
                                )
                            }
                            .tabItem {
                                Image(systemName: "person")
                                Text("Setting")
                            }
                            .tag("Setting")
                            .navigationViewStyle(.stack)
                        }
                        .onAppear {
                            UITabBar.appearance().backgroundColor = .white
                            UIDatePicker.appearance().minuteInterval = 5
                        }
                        .environmentObject(todoState)
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
