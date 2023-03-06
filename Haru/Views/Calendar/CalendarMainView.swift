//
//  CalendarMain.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CalendarMain: View {
    @State private var currentDate: Date = .init()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Custom Date Picker...
                CustomDatePicker(currentDate: $currentDate)
            }
        }
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMain()
    }
}
