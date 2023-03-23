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
    @Binding var scheduleList: [[Schedule]]
    @Binding var todoList: [[Todo]]

    var body: some View {
        Pager(page: page, data: self.data, id: \.self) { index in
            CalendarDayDetailView(currentScheduleList: $scheduleList[index], currentTodoList: $todoList[index], index: index)
                .frame(width: 330, height: 480)
                .cornerRadius(20)
        }
        .itemAspectRatio(0.8)
        .itemSpacing(30)
        .padding(8)
        .interactive(scale: 0.8)
        .interactive(opacity: 0.8)
        .onPageChanged { pageIndex in
            guard let first = self.data.first else { return }
            guard let last = self.data.last else { return }
            let frontData = first - 1
            let backData = last + 1
            withAnimation {
                self.data.insert(frontData, at: 0)
                self.data.append(backData)
            }
            self.page.index += 1
        }
        .frame(height: 480)
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDayView(scheduleList: .constant([]), todoList: .constant([]))
    }
}
