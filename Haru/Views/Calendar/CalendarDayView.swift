//
//  CalendarDayView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI
import SwiftUIPager

struct CalendarDayView: View {
    @StateObject var page: Page = .withIndex(15)

    @State var data = Array(0 ... 30)

    @StateObject var calendarViewModel: CalendarViewModel

    @State var prevPageIndex: Int = 15

    var body: some View {
        Pager(page: page, data: self.data.indices, id: \.self) { index in
            // TODO: todoAddViewModel 이렇게 사용해도 되는지 물어보기
//            CalendarDayDetailView(calendarVM: calendarViewModel, todoAddViewModel: TodoAddViewModel(checkListViewModel: CheckListViewModel()), row: index)
//                .frame(width: 330, height: 480)
//                .cornerRadius(20)
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
                guard let last = self.data.last else { return }
                self.data.append(contentsOf: last + 1 ... last + 5)
                self.data.removeFirst(5)
                calendarViewModel.getMoreProductivityList(isRight: true, offSet: 5) {
                    self.page.index -= 5
                    self.prevPageIndex -= 5
                }
            }

            if pageIndex == 4 {
                guard let first = self.data.first else { return }
                self.data.insert(contentsOf: first - 5 ... first - 1, at: 0)
                self.data.removeLast(5)
                calendarViewModel.getMoreProductivityList(isRight: false, offSet: 5) {
                    self.page.index += 5
                    self.prevPageIndex += 5
                }
            }

            prevPageIndex = self.page.index
            print("\(prevPageIndex)")
        }
        .frame(height: 480, alignment: .center)
    }
}
