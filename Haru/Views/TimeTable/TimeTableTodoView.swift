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
            }
            Spacer()
        }
        .padding(.leading, 24)
    }
}
