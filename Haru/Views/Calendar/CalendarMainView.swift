//
//  CalendarMain.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CalendarMainView: View {
    @State private var startOnSunday: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            // Custom Date Picker...
            CalendarDateView(startOnSunday: $startOnSunday, dateList: CalendarHelper.extractDate(0, startOnSunday))
        }
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainView()
    }
}
