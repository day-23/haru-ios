//
//  Store.swift
//  Haru
//
//  Created by 최정민 on 11/19/23.
//

import Foundation

typealias Action = Hashable & RawRepresentable
typealias UpdaterParameters = Any
typealias Updater<T> = (T, UpdaterParameters) -> T
typealias Reducer<T, A: Action> = [A: Updater<T>]

final class Store<T, A: Action>: ObservableObject {
    public let id: String
    @Published private(set) var state: T
    private(set) var reducer: Reducer<T, A> = [:]

    public func update(action: A, params: UpdaterParameters) {
        guard let updater = reducer[action] else {
            return
        }

        state = updater(state, params)
    }

    init(id: String = UUID().uuidString, initialState state: T, reducer: [A: Updater<T>]) {
        self.id = id
        self.state = state
        self.reducer = reducer
    }
}
