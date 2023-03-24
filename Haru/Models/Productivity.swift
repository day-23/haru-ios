//
//  Productivity.swift
//  Haru
//
//  Created by 이준호 on 2023/03/22.
//

import Foundation

protocol Productivity {
    var id: String { get }
    var content: String { get }
    func isEqualTo(_ other: Productivity) -> Bool
}

extension Productivity where Self: Equatable {
    func isEqualTo(_ other: Productivity) -> Bool {
        guard let otherProductivity = other as? Self else { return false }
        return self == otherProductivity
    }
}
