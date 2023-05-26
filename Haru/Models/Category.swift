//
//  Category.swift
//  Haru
//
//  Created by 이준호 on 2023/03/14.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: String
    private(set) var content: String
    private(set) var color: String?
//    private(set) var categoryOrder: Int?
    private(set) var isSelected: Bool

    // MARK: - Dates

//    let createdAt: Date
//    private(set) var updatedAt: Date?
//    private(set) var deletedAt: Date?
}

// MARK: - Extensions

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

extension Category {
    mutating func setContent(_ content: String) {
        self.content = content
    }

    mutating func toggleIsSelected() {
        self.isSelected.toggle()
    }
}
