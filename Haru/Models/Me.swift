//
//  Me.swift
//  Haru
//
//  Created by 이민재 on 2023/05/19.
//

import Foundation

struct Me: Hashable, Equatable, Identifiable, Codable {
    let id: String

    init(
        id: String
    ) {
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
    }
}
