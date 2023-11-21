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

    public func register<T, A: Action>(store: Store<T, A>) {
        if stores.keys.contains(store.id) {
            return
        }

        stores[store.id] = store
    }

    public func unregister(id: String) {
        stores.removeValue(forKey: id)
    }

    public func get<T, A: Action>(
        for type: T.Type,
        enumType: A.Type) -> [Store<T, A>]
    {
        var res: [Store<T, A>] = []

        for store in stores.values {
            if let store = store as? Store<T, A> {
                res.append(store)
            }
        }

        return res
    }

    public func get<T, A: Action>(
        storeId id: String,
        for type: T.Type,
        enumType: A.Type) -> Store<T, A>?
    {
        for store in get(for: type, enumType: enumType) {
            if store.id == id {
                return store
            }
        }

        return nil
    }

    public func dispatch<T, A: Action>(
        action: A,
        params: UpdaterParameters = [:],
        for type: T.Type)
    {
        for store in stores.values {
            if let store = store as? Store<T, A> {
                store.update(action: action, params: params)
            }
        }
    }

    public func dispatch<T, A: Action>(
        action: A,
        params: UpdaterParameters = [:],
        storeId id: String,
        for type: T.Type)
    {
        for store in stores.values {
            if let store = store as? Store<T, A> {
                if store.id == id {
                    store.update(action: action, params: params)
                    return
                }
            }
        }
    }
}

let Dispatcher = FluxDispatcher.default
