//
//  CalendarScheduleItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/09.
//

import SwiftUI

struct CalendarScheduleItem: View {
    @Binding var scheduleList: [(Int, Schedule?)]
    var cellWidth: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            ForEach(scheduleList.indices, id: \.self) { index in
                if let schedule = scheduleList[index].1 {
                    Text("\(schedule.content)")
                        .font(Font.custom(Constants.Regular, size: 12))
                        .padding(4)
                        .frame(width: cellWidth * CGFloat(scheduleList[index].0), alignment: .leading)
                        .background(Color(schedule.category?.color, true))
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: cellWidth * CGFloat(scheduleList[index].0))
                }
            }
        }
    }
}

// struct CalendarScheduleItem_Previews: PreviewProvider {
//    static var vm: CalendarViewModel = .init()
//    static var previews: some View {
//        CalendarScheduleItem(scheduleList: .constant(vm.scheduleList[0]), date: Date().day)
//    }
// }
