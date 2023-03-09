//
//  Day.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation

struct Day {
    var content: String
    var isClicked: Bool

    init(content: String, isClicked: Bool = false) {
        self.content = content
        self.isClicked = isClicked
    }
}
