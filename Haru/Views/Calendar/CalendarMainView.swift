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
        CalendarDateView()
            .environmentObject(calendarVM)
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainView()
    }
}
