//
//  Todo.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct Todo {
    var content: String

    mutating func setContent(_ content: String) {
        self.content = content
    }
}
