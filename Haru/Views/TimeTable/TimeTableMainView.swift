//
//  TimeTableMainView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct TimeTableMainView: View {
    //  MARK: - Properties

    @StateObject var timeTableViewModel: TimeTableViewModel

    private let column = [GridItem(.fixed(20)), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M"
        return formatter
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    init(timeTableViewModel: StateObject<TimeTableViewModel>) {
        _timeTableViewModel = timeTableViewModel
    }

    var body: some View {
        ZStack {
            VStack {
                //  날짜 레이아웃
                VStack {
                    HStack {
                        Text("\(monthFormatter.string(from: .now))월")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.leading)
                        Spacer()
                    }

                    Group {
                        LazyVGrid(columns: column) {
                            Text("")

                            ForEach(week, id: \.self) { day in
                                Text(day)
                            }
                        }

                        Divider()
                            .padding(.leading, 30)

                        LazyVGrid(columns: column) {
                            Text("")

                            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                                Text(dayFormatter.string(from: timeTableViewModel.thisWeek[index]))
                            }
                        }

                        TimeTableScheduleView(
                            timeTableViewModel: _timeTableViewModel
                        )
                    }
                }
            }
            .padding(.trailing)
        }
        .onAppear {
            timeTableViewModel.fetchScheduleList()
        }
    }
}
