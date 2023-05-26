//
//  Global.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation
import SwiftUI

final class Global: ObservableObject {
    private init() {}

    static let shared: Global = .init()
    @Published var user: Me?
    var hashTagAll = HashTag(id: UUID().uuidString, content: "전체보기")

    @Published var isTabViewActive: Bool = true
    @Published var isFaded: Bool = false
}
