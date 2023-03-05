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
            Text("Calendar SubView")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(2)
            Text("Check-List SubView")
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Check-List")
                }
                .tag(3)
            Text("Time-Table SubView")
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("Time-Table")
                }
                .tag(4)

            Modal()
                .tabItem {
                    Image(systemName: "person")
                    Text("Setting")
                }
                .tag(5)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(selection: 3)
    }
}
