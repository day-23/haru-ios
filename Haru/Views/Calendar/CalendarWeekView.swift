//
//  CalendarWeekView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/21.
//

import SwiftUI

struct CalendarWeekView: View {
    @StateObject var calendarVM: CalendarViewModel

    @Binding var isDayModalVisible: Bool

    var cellHeight: CGFloat
    var cellWidth: CGFloat

    var body: some View {
        Group {
            VStack(spacing: 0) {
                let dateColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                ForEach(0 ..< calendarVM.numberOfWeeks, id: \.self) { week in
                    ZStack(alignment: .bottom) {
                        LazyVGrid(columns: dateColumns, spacing: 0) {
                            ForEach(0 ..< 7, id: \.self) { day in
                                CalendarDateItem(selectionSet: calendarVM.selectionSet, value: calendarVM.dateList[week * 7 + day], cellHeight: cellHeight, cellWidth: cellWidth)
                                    .onTapGesture {
                                        calendarVM.pivotDate = calendarVM.dateList[week * 7 + day].date
                                        calendarVM.getSelectedScheduleList()
                                        withAnimation {
                                            isDayModalVisible = true
                                            Global.shared.isFaded = true
                                        }
                                    }
                            }
                        }

                        VStack(spacing: 2) {
                            Spacer().frame(height: 26)
                            ForEach(0 ..< calendarVM.maxOrder, id: \.self) { order in
                                CalendarScheduleItem(
                                    productivityList: $calendarVM.viewProductivityList[week][order],
                                    cellWidth: cellWidth,
                                    month: calendarVM.dateList.isEmpty ?
                                        Date().month : calendarVM.dateList[10].date.month
                                )
                            }
                            moreText(week: week, dateColumns: dateColumns)
                        }
                        .frame(width: cellWidth * 7, height: cellHeight, alignment: .top)
                    }
                    .border(width: 1, edges: [.top], color: Color(0xdbdbdb))
                }
            }
        } // Group
    }

    @ViewBuilder
    func moreText(week: Int, dateColumns: [GridItem]) -> some View {
        LazyVGrid(columns: dateColumns, spacing: 0) {
            ForEach(0 ..< 7, id: \.self) { day in
                if let moreCnt = getMoreCnt(week: week, day: day) {
                    Text("+\(moreCnt)")
                        .font(.pretendard(size: 12, weight: .regular))
                        .padding(4)
                        .frame(width: cellWidth - 4, height: 16, alignment: .center)
                        .background(Color.gray3)
                        .cornerRadius(4)
                        .opacity(calcOpacity(dateValue: calendarVM.dateList[week * 7 + day]))
                } else {
                    Spacer()
                }
            }
        }
    }

    func getMoreCnt(week: Int, day: Int) -> Int? {
        calendarVM.productivityList[week * 7 + day][calendarVM.maxOrder]?.count
    }

    func calcOpacity(dateValue: DateValue) -> Double {
        dateValue.isNextDate || dateValue.isPrevDate ? 0.3 : 1
    }
}
