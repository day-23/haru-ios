//
//  StarButton.swift
//  Haru
//
//  Created by 최정민 on 2023/03/22.
//

import SwiftUI

struct StarButton: View {
    var isClicked: Bool

    var body: some View {
        Image(isClicked ? "star-check" : "star")
            .zIndex(1)
            .frame(width: 28, height: 28)
    }
}
