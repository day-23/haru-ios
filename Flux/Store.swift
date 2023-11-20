//
//  Store.swift
//  Haru
//
//  Created by 최정민 on 11/19/23.
//

import Foundation

final class Store<T>: ObservableObject {
    typealias Action = (T) -> T

    public let id: String
    @Published private(set) var state: T
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
