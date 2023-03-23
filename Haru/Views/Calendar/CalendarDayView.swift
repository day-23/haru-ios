//
//  CalendarDayView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/23.
//

import SwiftUI
import SwiftUIPager

struct CalendarDayView: View {
    @StateObject var page: Page = .withIndex(2)

    @State var data = Array(0 ..< 10)

    var body: some View {
        Pager(page: page, data: self.data, id: \.self) { index in
            CalendarDayDetailView()
            .frame(width: 330, height: 480)
            .cornerRadius(20)
        }
        .itemAspectRatio(0.8)
        .itemSpacing(30)
        .padding(8)
        .interactive(scale: 0.8)
        .interactive(opacity: 0.8)
        .onPageChanged { pageIndex in
            guard pageIndex == self.data.count - 2 else { return }
            guard let last = self.data.last else { return }
            let newData = (1 ... 5).map { last + $0 }
            withAnimation {
                self.data.append(contentsOf: newData)
            }
        }
        .frame(height: 480)
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDayView()
    }
}
