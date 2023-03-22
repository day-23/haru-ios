//
//  CalendarScheduleItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/09.
//

import SwiftUI

struct CalendarScheduleItem: View {
    @Binding var productivityList: [(Int, Productivity?)]
    var cellWidth: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            ForEach(productivityList.indices, id: \.self) { index in
                if let producitiviy = productivityList[index].1, let schedule = producitiviy as? Schedule {
                    Text("\(schedule.content)")
                        .font(Font.custom(Constants.Regular, size: 12))
                        .padding(4)
                        .frame(width: cellWidth * CGFloat(productivityList[index].0), alignment: .leading)
                        .background(Color(schedule.category?.color, true))
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: cellWidth * CGFloat(productivityList[index].0))
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
