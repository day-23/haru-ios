//
//  CalendarDayView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI
import SwiftUIPager

struct CalendarDayView: View {
    @EnvironmentObject private var todoState: TodoState

    @StateObject var page: Page = .withIndex(15)

    @State var data = Array(0 ... 30)

    @StateObject var calendarViewModel: CalendarViewModel

    @State var prevPageIndex: Int = 15

    var body: some View {
        Pager(page: page, data: data.indices, id: \.self) { index in
            CalendarDayDetailView(
                calendarVM: calendarViewModel,
                todoAddViewModel: TodoAddViewModel(todoState: todoState, addAction: { todoId in
                }, updateAction: { todoId in
                    calendarViewModel.getRefreshProductivityList()
                }, deleteAction: { todoId in
                    calendarViewModel.getRefreshProductivityList()
                }),
                row: index
            )
            .frame(width: 330, height: 480)
            .cornerRadius(20)
        }
        .itemAspectRatio(0.8)
        .itemSpacing(30)
        .padding(8)
        .interactive(scale: 0.8)
        .interactive(opacity: 0.8)
        .onPageChanged { pageIndex in
            if prevPageIndex < pageIndex {
                calendarViewModel.pivotDate = calendarViewModel.pivotDate.addDay()
            } else {
                calendarViewModel.pivotDate = calendarViewModel.pivotDate.subtractDay()
            }

            if pageIndex == data.count - 5 {
                guard let last = data.last else { return }
                data.append(contentsOf: last + 1 ... last + 5)
                data.removeFirst(5)
                calendarViewModel.getMoreProductivityList(isRight: true, offSet: 5) {
                    page.index -= 5
                    prevPageIndex -= 5
                }
            }

            if pageIndex == 4 {
                guard let first = data.first else { return }
                data.insert(contentsOf: first - 5 ... first - 1, at: 0)
                data.removeLast(5)
                calendarViewModel.getMoreProductivityList(isRight: false, offSet: 5) {
                    page.index += 5
                    prevPageIndex += 5
                }
            }

            prevPageIndex = page.index
            print("\(prevPageIndex)")
        }
        .frame(height: 480, alignment: .center)
    }
}
