//
//  SlideOptionView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/31.
//

import SwiftUI

struct SlideOptionView: View {
    var calendarVM: CalendarViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)

                CalendarOptionView(calendarVM: calendarVM)
                    .frame(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.height - 200)
                    .background(
                        Image("background-manage")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.height - 200)
                    )
                    .cornerRadius(10, corners: [.topLeft, .bottomLeft])
            }
            Spacer(minLength: 0)
        }
    }
}

struct SlideOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SlideOptionView(calendarVM: CalendarViewModel())
    }
}
