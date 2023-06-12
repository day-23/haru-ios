//
//  StarButton.swift
//  Haru
//
//  Created by 최정민 on 2023/03/22.
//

import SwiftUI

struct StarButton: View {
    var isClicked: Bool
    var completed: Bool = false

    var body: some View {
        Image(self.isClicked ? "todo-star-fill\(completed ? "-transparent" : "")" : "todo-star\(completed ? "-transparent" : "")")
            .zIndex(1)
            .frame(width: 28, height: 28)
    }
}
