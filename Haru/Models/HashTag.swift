//
//  HashTag.swift
//  Haru
//
//  Created by 이준호 on 2023/05/16.
//

import Foundation

struct HashTag: Codable, Identifiable {
    let id: String
    var content: String
}

extension HashTag: Equatable {
    static func == (lhs: HashTag, rhs: HashTag) -> Bool {
        lhs.id == rhs.id
    }
}
