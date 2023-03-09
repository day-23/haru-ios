//
//  CalendarMain.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CalendarMainView: View {
    var body: some View {
        VStack(spacing: 20) {
            CalendarDateView()
        }
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainView()
    }
}
