//
//  Dispatcher.swift
//  Haru
//
//  Created by 최정민 on 11/19/23.
//

import Foundation

final class Dispatcher {
    private init() {}
    public static let `default`: Dispatcher = .init()

    private var stores: [Any] = []

    public func register<T>(store: Store<T>) {
        if !stores.contains(where: { elem in
            guard let elem = elem as? Store<T> else {
                return false
            }

            return elem == store
        }) {
            stores.append(store)
        }
    }

    public func dispatch<T>(key: String, for type: T.Type) {
        for store in stores {
            if let store = store as? Store<T> {
                store.update(key: key)
            }
        }
    }

    public func dispatch<T>(key: String, for type: T.Type, id: String) {
        for store in stores {
            if let store = store as? Store<T>, store.id == id {
                store.update(key: key)
            }
        }
    }
}
