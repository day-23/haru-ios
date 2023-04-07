//
//  TimeTableScheduleTopView.swift
//  Haru
//
//  Created by 최정민 on 2023/04/07.
//

import SwiftUI

struct TimeTableScheduleTopView: View {
    @StateObject var timeTableViewModel: TimeTableViewModel

    private var fixed: Double = 31
    @State private var topItemWidth: Double = 48
    private var topItemHeight: Double = 18

    private let column = [GridItem(.fixed(31)), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    init(timeTableViewModel: StateObject<TimeTableViewModel>) {
        _timeTableViewModel = timeTableViewModel
    }

    var body: some View {
        LazyVGrid(columns: column) {
            Text("")

            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                Rectangle()
                    .foregroundColor(.white)
                    .frame(height: topItemHeight * CGFloat(timeTableViewModel.maxRowCount) + Double(timeTableViewModel.maxRowCount))
                    .background(
                        GeometryReader(content: { proxy in
                            Color.clear.onAppear {
                                topItemWidth = proxy.size.width
                            }
                        })
                    )
            }
        }
        .overlay {
            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                ForEach($timeTableViewModel.scheduleListWithoutTime[index]) { $schedule in
                    ScheduleTopItemView(
                        schedule: $schedule, width: topItemWidth * CGFloat(schedule.weight), height: topItemHeight
                    )
                    .position(
                        calcTopItemPosition(weight: schedule.weight, index: index, order: schedule.order)
                    )
                }
            }
        }
    }
}

extension TimeTableScheduleTopView {
    func calcTopItemPosition(
        weight: Int,
        index: Int,
        order: Int
    ) -> CGPoint {
        var x = topItemWidth * Double(index + 1)
        x += fixed + 8
        x -= topItemWidth * Double(weight) * 0.5
        x += topItemWidth * Double(weight) * (Double(weight - 1) / Double(weight))

        var y = topItemHeight * Double(order)
        y -= topItemHeight * 0.5
        y += Double(order) * 2
        return CGPoint(x: x, y: y)
    }
}
