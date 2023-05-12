//
//  DayButton.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct DayButton: View {
    var content: String
    var isClicked: Bool
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(content)
                .foregroundColor(
                    disabled
                        ? Color(0xF71E58)
                        : (isClicked
                            ? Color(0x1DAFFF)
                            : Color(0xACACAC)))
                .font(.pretendard(size: 14, weight: .regular))
        }
        .disabled(disabled)
    }
}
