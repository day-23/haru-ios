//
//  SubTodo.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct SubTodo: Codable, Identifiable {
    // MARK: - Properties

    let id: String
    private(set) var content: String

    // MARK: - Dates

    let createdAt: Date
    private(set) var updatedAt: Date
    private(set) var deletedAt: Date?
}
