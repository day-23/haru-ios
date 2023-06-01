//
//  CalendarMain.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CalendarMainView: View {
    @StateObject var calendarVM: CalendarViewModel
    @StateObject var addViewModel: TodoAddViewModel

    var body: some View {
        CalendarDateView(
            calendarVM: calendarVM,
            addViewModel: addViewModel
        )
    }
}
