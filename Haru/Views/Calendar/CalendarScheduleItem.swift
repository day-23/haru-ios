//
//  CalendarScheduleItem.swift
//  Haru
//
//  Created by 이준호 on 2023/03/09.
//

import SwiftUI

struct CalendarScheduleItem: View {
    @Binding var scheduleList: [Int: [Schedule]]
    var date: Int

    var body: some View {
        VStack(spacing: 3) {
            ForEach(0 ..< 4, id: \.self) { order in
                if let value = scheduleList[order]?.first {
                    Rectangle()
                        .fill(Color(value.category?.color, true))
                        .frame(height: 20)
                        .cornerRadius(date == value.repeatStart.day ? 6 : 0, corners: [.topLeft, .bottomLeft])
                        .cornerRadius(date == value.repeatEnd.day ? 6 : 0, corners: [.topRight, .bottomRight])
                        .overlay {
                            if date == value.repeatStart.day {
                                Text(value.content)
                                    .font(Font.custom(Constants.Regular, size: 12))
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }

                } else {
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
    }
}

//struct CalendarScheduleItem_Previews: PreviewProvider {
//    static var vm: CalendarViewModel = .init()
//    static var previews: some View {
//        CalendarScheduleItem(scheduleList: .constant(vm.scheduleList[0]), date: Date().day)
//    }
//}
