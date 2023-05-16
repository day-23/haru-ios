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

    var body: some View {
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
                CheckListView(
                    viewModel: CheckListViewModel(todoState: _todoState),
                    addViewModel: TodoAddViewModel(todoState: todoState)
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
    }
}
