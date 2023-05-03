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
        VStack(spacing: 0) {
            HaruHeader {
                // TODO: 검색 뷰 만들어지면 넣어주기
                Text("검색")
            }
            CalendarDateView(calendarVM: calendarVM)
        }
    }
}

struct CalendarMain_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainView()
    }
}
