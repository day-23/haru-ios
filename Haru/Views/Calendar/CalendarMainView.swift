//
//  CalendarMain.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CalendarMainView: View {
    
    @ObservedObject var calendarVM: CalendarViewModel = .init()
    
    var body: some View {
        VStack(spacing: 20) {
            CalendarDateView(calendarVM: calendarVM)
        }
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainView()
    }
}
