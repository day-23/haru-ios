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
                        Text("\(String(timeTableViewModel.currentYear))년")
                            .font(.pretendard(size: 28, weight: .bold))
                            .foregroundColor(Color(0x191919))
                            .padding(.leading, 40)
                        Text("\(timeTableViewModel.currentMonth)월")
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
                        TimeTableScheduleView(
                            timeTableViewModel: _timeTableViewModel
                        )
                    } else {
                        TimeTableTodoView(
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

extension TimeTableMainView {}
