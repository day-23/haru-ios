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
}

// MARK: - Extensions

extension Category {
    mutating func setContent(_ content: String) {
        self.content = content
    }
}
