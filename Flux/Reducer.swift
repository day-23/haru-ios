//
//  Reducer.swift
//  Haru
//
//  Created by 최정민 on 11/20/23.
//

import Foundation

final class Reducer<T> {
    private(set) var actions: Action<T>

    init(actions: Action<T>) {
        self.actions = actions
    }

    public func update(key: String) {
        switch key {}
    }
}
