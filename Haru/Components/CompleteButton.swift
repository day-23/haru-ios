//
//  CompleteButton.swift
//  Haru
//
//  Created by 최정민 on 2023/03/21.
//

import SwiftUI

struct CompleteButton: View {
    var isClicked: Bool

    var body: some View {
        ZStack {
            Image(isClicked ? "check-completed-circle" : "check-circle")
                .zIndex(1)
                .frame(width: 16, height: 16)
        }
        .frame(width: 28, height: 28)
    }
}
