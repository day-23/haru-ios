//
//  Tag.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct Tag: Codable, Identifiable {
    // MARK: - Properties

    let id: String
    var content: String
    var isSelected: Bool

    init(id: String, content: String, isSelected: Bool = true) {
        self.id = id
        self.content = content
        self.isSelected = isSelected
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        do {
            self.isSelected = try container.decode(Bool.self, forKey: .isSelected)
        } catch {
            self.isSelected = true
        }
    }

    // MARK: - Dates Properties

//    let createdAt: Date
//    private(set) var updatedAt: Date
//    private(set) var deletedAt: Date?
}
