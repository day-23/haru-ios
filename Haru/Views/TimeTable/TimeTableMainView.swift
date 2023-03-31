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

    private let column = [GridItem(.fixed(31)), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0),
                          GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    private let week = ["일", "월", "화", "수", "목", "금", "토"]

    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

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

    @State private var isScheduleView: Bool = true

    init(timeTableViewModel: StateObject<TimeTableViewModel>) {
        _timeTableViewModel = timeTableViewModel
    }

    var body: some View {
        ZStack {
            VStack {
                //  날짜 레이아웃
                VStack {
                    HStack(spacing: 0) {
                        Text("\(yearFormatter.string(from: .now))년")
                            .font(.pretendard(size: 28, weight: .bold))
                            .foregroundColor(Color(0x191919))
                            .padding(.leading, 40)
                        Text("\(monthFormatter.string(from: .now))월")
                            .font(.pretendard(size: 28, weight: .bold))
                            .foregroundColor(Color(0x191919))
                            .padding(.leading, 10)
                        Image("toggle")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x767676))
                            .rotationEffect(Angle(degrees: 90))
                            .scaleEffect(1.25)
                            .scaledToFit()
                            .padding(.leading, 10)

                        Spacer()

                        Text("\(Date().day)")
                            .font(.pretendard(size: 12, weight: .bold))
                            .foregroundColor(Color(0x2ca4ff))
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .background(
                                Circle()
                                    .stroke(.gradation1, lineWidth: 2)
                            )
                            .padding(.trailing, 16)

                        Image(isScheduleView ? "time-table-todo" : "time-table-schedule")
                            .onTapGesture {
                                isScheduleView.toggle()
                            }
                    }

                    if isScheduleView {
                        LazyVGrid(columns: column) {
                            Text("")

                            ForEach(week, id: \.self) { day in
                                Text(day)
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .foregroundColor(
                                        day == "일" ? Color(0xf71e58) : (day == "토" ? Color(0x1dafff) : Color(0x191919))
                                    )
                            }
                        }

                        Divider()
                            .padding(.leading, 40)
                            .foregroundColor(Color(0xdbdbdb))

                        LazyVGrid(columns: column) {
                            Text("")

                            ForEach(timeTableViewModel.thisWeek.indices, id: \.self) { index in
                                Text(dayFormatter.string(from: timeTableViewModel.thisWeek[index]))
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .foregroundColor(
                                        index == 0 ? Color(0xf71e58) : (index == 6 ? Color(0x1dafff) : Color(0x191919))
                                    )
                            }
                        }

                        TimeTableScheduleView(
                            timeTableViewModel: _timeTableViewModel
                        )
                    } else {
                        TimeTableTodoView()
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
