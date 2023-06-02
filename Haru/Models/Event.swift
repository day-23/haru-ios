//
//  Event.swift
//  Haru
//
//  Created by 이준호 on 2023/03/22.
//  Updated by 최정민 on 2023/05/31.
//

import Foundation

protocol Event {
    var id: String { get }
    var content: String { get }
    func isEqualTo(_ other: Event) -> Bool
}

extension Event where Self: Equatable {
    func isEqualTo(_ other: Event) -> Bool {
        guard let otherProductivity = other as? Self else { return false }
        return self == otherProductivity
    }
}
