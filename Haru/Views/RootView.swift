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
                            TabView(selection: $selection) {
                                // MARK: - SNS View

                                SNSView()
                                    .tabItem {
                                        Image(systemName: "paperplane")
                                        Text("SNS")
                                    }
                                    .tag(0)
                                
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
                                .tabItem {
                                    Image(systemName: "checklist")
                                    Text("Check-List")
                                }
                                .tag(1)
                                
                                // MARK: - Calendar View
                                
                                CalendarMainView()
                                    .tabItem {
                                        Image(systemName: "calendar")
                                        Text("Calendar")
                                    }
                                    .tag(2)
                                
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
                                .tabItem {
                                    Image(systemName: "calendar.day.timeline.left")
                                    Text("Time-Table")
                                }
                                .tag(3)
                                
                                // MARK: - Setting View
                                
                                MyView(
                                    isLoggedIn: $isLoggedIn
                                )
                                .tabItem {
                                    Image(systemName: "person")
                                    Text("Setting")
                                }
                                .tag(4)
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
