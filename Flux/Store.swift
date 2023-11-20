//
//  Store.swift
//  Haru
//
//  Created by 최정민 on 11/19/23.
//

import Foundation

final class Store<T> {
    typealias Action = (T) -> T

    static func == (lhs: Store<T>, rhs: Store<T>) -> Bool {
        return lhs.id == rhs.id
    }

    public let id: String
    private var state: T
    private(set) var reducer: [String: Action] = [:]

    public func update(key: String) {
        guard let action = reducer[key] else {
            return
        }

        state = action(state)
    }

    init(id: String = UUID().uuidString, initialState state: T, reducer: [String: Action]) {
        self.id = id
        self.state = state
        self.reducer = reducer
    }
}
