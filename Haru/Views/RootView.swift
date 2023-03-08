//
//  RootView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/05.
//

import Foundation
import SwiftUI

struct RootView: View {
    @State var selection: Int = 3

    var body: some View {
        TabView(selection: $selection) {
            Text("SNS SubView")
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("SNS")
                }
                .tag(1)
            CalendarMainView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(2)
            Text("Todo SubView")
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Todo")
                }
                .tag(3)
            Text("TimeTable SubView")
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("TimeTable")
                }
                .tag(4)
            Text("Setting SubView")
                .tabItem {
                    Image(systemName: "person")
                    Text("Setting")
                }
                .tag(5)
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = .white
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(selection: 3)
    }
}
