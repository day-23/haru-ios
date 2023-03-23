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
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(content)
                .foregroundColor(isClicked ? Color(0x1DAFFF) : Color(0xACACAC))
                .font(.system(size: 14))
        }
    }
}
