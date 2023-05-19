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
    var isSelected: Bool = true

    // MARK: - Dates Properties

//    let createdAt: Date
//    private(set) var updatedAt: Date
//    private(set) var deletedAt: Date?
}
