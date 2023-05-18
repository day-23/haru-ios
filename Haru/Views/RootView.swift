//
//  RootView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/05.
//

import Foundation
import SwiftUI

struct RootView: View {
    @StateObject private var todoState: TodoState = .init()
    @State private var showSplash: Bool = true
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            ZStack {
                if showSplash {
                    SplashView(
                        isLoggedIn: $isLoggedIn
                    )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    if isLoggedIn {
                        TabView {
                            NavigationView {
                                SNSView()
                            }
                            .tabItem {
                                Image(systemName: "paperplane")
                                Text("SNS")
                            }
                            .tag("SNS")
                            .navigationViewStyle(.stack)
                                
                            NavigationView {
                                CalendarMainView()
                            }
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("Calendar")
                            }
                            .tag("Calendar")
                            .navigationViewStyle(.stack)
                                
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
                                
                            NavigationView {
                                TimeTableMainView(
                                    timeTableViewModel: .init(wrappedValue: TimeTableViewModel())
                                )
                            }
                            .tabItem {
                                Image(systemName: "calendar.day.timeline.left")
                                Text("Time-Table")
                            }
                            .tag("Time-Table")
                            .navigationViewStyle(.stack)
                                
                            NavigationView {
                                Text("Setting SubView")
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
                    } else {
                        Login(
                            isLoggedIn: $isLoggedIn
                        )
                    }
                }
            }
        }
    }
}
