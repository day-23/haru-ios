//
//  DropdownMenu.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct DropdownMenu<F, S>: View where F: View, S: View {
    let firstContent: () -> F
    let secondContent: () -> S

    init(firstContent: @escaping () -> F, secondContent: @escaping () -> S) {
        self.firstContent = firstContent
        self.secondContent = secondContent
    }

    var body: some View {
        VStack(spacing: 6) {
            Group {
                firstContent()

                Divider()

                secondContent()
            }
            .foregroundColor(Color(0x191919))
            .font(.pretendard(size: 14, weight: .regular))
        }
        .frame(width: 100, height: 50)
        .padding(.vertical, 8)
        .background(Color(0xFDFDFD))
        .cornerRadius(10)
        .position(x: 60, y: 75)
        .transition(.opacity.animation(.easeIn))
        .shadow(radius: 10)
    }
}

// struct DropdownMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        DropdownMenu()
//    }
// }
