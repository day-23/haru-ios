//
//  Action.swift
//  Haru
//
//  Created by 최정민 on 11/19/23.
//

import Foundation

final class Action<T> {
    private(set) var key: String
    private(set) var updater: (T) -> T

    init(key: String, updater: @escaping (T) -> T) {
        self.key = key
        self.updater = updater
    }
}
