//
//  DayButton.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct DayButton: View {
    var disabled: Bool
    var content: String
    var isClicked: Bool
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(content)
                .padding()
                .foregroundColor(isClicked && !disabled ? .blue : Color(0x000000, opacity: 0.3))
        }
        .disabled(disabled)
    }
}
