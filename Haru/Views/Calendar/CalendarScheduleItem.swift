//
//  CalendarScheduleItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/09.
//

import SwiftUI

struct CalendarScheduleItem: View {
    let widthSize: CGFloat
    let heightSize: CGFloat
    @Binding var scheduleList: [Schedule]

    var body: some View {
        VStack {
            ForEach(scheduleList.prefix(3)) { list in
                VStack(spacing: 0) {
                    Text(list.content)
                }
            }
            
        }
    }
}

struct CalendarScheduleItem_Previews: PreviewProvider {
    static var vm: CalendarViewModel = .init()
    static var previews: some View {
        CalendarScheduleItem(widthSize: 393.0, heightSize: 612.6666666666666 / CGFloat(vm.numberOfWeeks) - 32, scheduleList: .constant(vm.scheduleList[0]))
    }
}
