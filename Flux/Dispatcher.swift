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

    private var stores: [String: Any] = [:]

    public func get<T>(for type: T.Type) -> [Store<T>] {
        var res: [Store<T>] = []

        for store in stores.values {
            if let store = store as? Store<T> {
                res.append(store)
            }
        }

        return res
    }

    public func get<T>(id: String, for type: T.Type) -> Store<T>? {
        for store in get(for: type) {
            if store.id == id {
                return store
            }
        }
        return nil
    }

    public func register<T>(store: Store<T>) {
        if stores.keys.contains(store.id) {
            return
        }

        stores[store.id] = store
    }

    public func dispatch<T>(key: String, for type: T.Type) {
        for store in get(for: type) {
            store.update(key: key)
        }
    }

    public func dispatch<T>(key: String, for type: T.Type, id: String) {
        for store in stores.values {
            if let store = store as? Store<T>, store.id == id {
                store.update(key: key)
                return
            }
        }
    }
}
