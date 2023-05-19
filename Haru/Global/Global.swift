//
//  Global.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation

final class Global {
    private init() {}

    static let shared: Global = .init()
    var user: User?
}
