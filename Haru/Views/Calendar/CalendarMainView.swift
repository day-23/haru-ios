//
//  CalendarMain.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CalendarMainView: View {
    @StateObject var calendarVM: CalendarViewModel = .init()

    var body: some View {
        TabView(selection: $calendarVM.monthOffest) {
            ForEach(-100 ... 100, id: \.self) { _ in
                CalendarDateView()
                    .environmentObject(calendarVM)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainView()
    }
}
