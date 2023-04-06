//
//  TimeTableTodoView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/31.
//

import SwiftUI

struct TimeTableTodoView: View {
    //  MARK: - Properties

    @StateObject var timeTableViewModel: TimeTableViewModel

    init(timeTableViewModel: StateObject<TimeTableViewModel>) {
        _timeTableViewModel = timeTableViewModel
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                TimeTableTodoRow(
                    index: index,
                    date: timeTableViewModel.thisWeek[index]
                )
                .background(
                    index == Date.now.indexOfWeek() ? LinearGradient(
                        gradient: Gradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF), Color(0xAAD7FF)]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ) : LinearGradient(
                        colors: [.white],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
            }
            Spacer()
        }
    }
}
