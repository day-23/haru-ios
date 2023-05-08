//
//  DropdownMenu.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct DropdownMenu<F, S, T>: View where F: View, S: View, T: View {
    let firstContent: () -> F
    let secondContent: () -> S
    let thirdContent: () -> T

    init(firstContent: @escaping () -> F, secondContent: @escaping () -> S, thirdContent: @escaping () -> T) {
        self.firstContent = firstContent
        self.secondContent = secondContent
        self.thirdContent = thirdContent
    }

    var body: some View {
        VStack {
            Group {
                firstContent()

                Divider()

                secondContent()

                Divider()

                thirdContent()
            }
            .foregroundColor(Color(0x191919))
            .font(.pretendard(size: 14, weight: .regular))
        }
        .frame(width: 94, height: 96)
        .padding(8)
        .background(Color(0xFDFDFD))
        .cornerRadius(10)
        .position(x: 60, y: 90)
        .transition(.opacity.animation(.easeIn))
        .shadow(radius: 10)
    }
}

// struct DropdownMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        DropdownMenu()
//    }
// }
