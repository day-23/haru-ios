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
                if let productivity = productivityList[index].1 {
                    if let schedule = productivity as? Schedule {
                        Text("\(schedule.content)")
                            .font(.pretendard(size: 12, weight: .regular))
                            .padding(4)
                            .frame(width: cellWidth * CGFloat(productivityList[index].0), height: 16, alignment: .leading)
                            .background(Color(schedule.category?.color, true))
                            .cornerRadius(4)
                            .padding(.horizontal, 2)
                    } else if let todo = productivity as? Todo {
                        Text("\(todo.content)")
                            .font(.pretendard(size: 12, weight: .regular))
                            .frame(width: cellWidth * CGFloat(productivityList[index].0), height: 16)
                    }
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: cellWidth * CGFloat(productivityList[index].0), height: 16)
                }
            }
        }
    }
}

// struct CalendarScheduleItem_Previews: PreviewProvider {
//    static var vm: CalendarViewModel = .init()
//    static var previews: some View {
//        CalendarScheduleItem(productivityList: $vm.productivityList, cellWidth: 120)
//    }
// }
