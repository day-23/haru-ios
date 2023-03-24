//
//  Global.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation

final class Global {
    static let shared: Global = .init()
    var user: User? = User(id: "005224c0-eec1-4638-9143-58cbfc9688c5")
    private init() {}
}
