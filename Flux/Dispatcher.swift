//
//  Dispatcher.swift
//  Haru
//
//  Created by 최정민 on 11/19/23.
//

import Foundation

final class FluxDispatcher {
    private init() {}
    public static let `default`: FluxDispatcher = .init()

    private var stores: [String: Any] = [:]

    public func register<T>(store: Store<T>) {
        if stores.keys.contains(store.id) {
            return
        }

        stores[store.id] = store
    }

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

    public func dispatch<T>(key: String, params: [String: Any] = [:], for type: T.Type) {
        for store in get(for: type) {
            store.update(key: key, params: params)
        }
    }

    public func dispatch<T>(key: String, params: [String: Any] = [:], id: String, for type: T.Type) {
        for store in get(for: type) {
            if store.id == id {
                store.update(key: key, params: params)
                return
            }
        }
    }
}

let Dispatcher = FluxDispatcher.default
