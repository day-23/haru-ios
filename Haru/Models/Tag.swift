//
//  Tag.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct Tag {
    let id: String
    private(set) var content: String
    let createdAt: Date
    private(set) var updatedAt: Date
    private(set) var deletedAt: Date?
    private(set) var tagWithTodo: [TagWithTodo]
    // private(set) var tagWithPost: [TagWithPost]
}
