//
//  CalendarScheduleItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/09.
//

import SwiftUI

struct CalendarScheduleItem: View {
//    @EnvironmentObject var caledarVM: CalendarViewModel
    let widthSize: Double
    let heightSize: Double
    @Binding var scheduleList: [Schedule]
//    @Binding var numberOfWeeks: Int

    var body: some View {
        VStack {
            ForEach(scheduleList) { list in
                VStack(spacing: 5) {
                    Text(list.content)
                }
            }
        }
    }
}

struct CalendarScheduleItem_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScheduleItem(widthSize: 393.0, heightSize: 612.6666666666666, scheduleList: .constant([]))
    }
}
