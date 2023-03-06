//
//  RootView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/05.
//

import Foundation
import SwiftUI

struct RootView: View {
    @State private var selectedTab: Tab = .checkList

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tab.view
                    .tabItem {
                        Image(systemName: tab.systemImageName)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = .white
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
