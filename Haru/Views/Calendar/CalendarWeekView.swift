//
//  CalendarWeekView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/21.
//

import SwiftUI

struct CalendarWeekView: View {
    @EnvironmentObject var calendarVM: CalendarViewModel

    @Binding var isDayModalVisible: Bool

    var cellHeight: CGFloat
    var cellWidhth: CGFloat

    var body: some View {
        Group {
            VStack(spacing: 0) {
                let dateColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                ForEach(0 ..< calendarVM.numberOfWeeks, id: \.self) { week in
                    ZStack(alignment: .bottom) {
                        LazyVGrid(columns: dateColumns, spacing: 0) {
                            ForEach(0 ..< 7, id: \.self) { day in
                                CalendarDateItem(selectionSet: $calendarVM.selectionSet, value: calendarVM.dateList[week * 7 + day], cellHeight: cellHeight, cellWidhth: cellWidhth)
                                    .onTapGesture {
                                        calendarVM.selectedDate = calendarVM.dateList[week * 7 + day]
                                        calendarVM.getSelectedScheduleList(week * 7 + day)
                                        isDayModalVisible = true
                                    }
                            }
                        }
                        VStack(spacing: 2) {
                            Spacer().frame(height: 24)
                            // TODO: 아래 코드 보기 좋게 만들기
                            ForEach(0 ..< (calendarVM.numberOfWeeks < 6 ? 4 : 3), id: \.self) { order in
                                CalendarScheduleItem(productivityList: $calendarVM.viewProductivityList[week][order], cellWidth: cellWidhth)
                            }
                        }
                        .frame(width: cellWidhth * 7, height: cellHeight, alignment: .top)
                    }
                    .border(width: 0.5, edges: [.top], color: .gray1)
                }
            }
        } // Group
    }
}

struct CalendarWeekView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWeekView(isDayModalVisible: .constant(false), cellHeight: 120, cellWidhth: UIScreen.main.bounds.width / 7)
            .environmentObject(CalendarViewModel())
    }
}
