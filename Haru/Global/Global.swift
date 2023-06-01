//
//  Global.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation
import SwiftUI
import UserNotifications

final class Global: ObservableObject {
    private init() {}

    static let shared: Global = .init()
    @Published var user: Me?
    var hashTagAll = HashTag(id: UUID().uuidString, content: "전체보기")

    @Published var isTabViewActive: Bool = true
    @Published var isFaded: Bool = false

    var colors = [
        [Color(0x2E2E2E), Color(0x656565), Color(0x818181), Color(0x9D9D9D), Color(0xB9B9B9), Color(0xD5D5D5)],

        [Color(0xFF0959), Color(0xFF509C), Color(0xFF5AB6), Color(0xFE7DCD), Color(0xFFAAE5), Color(0xFFBDFB)],

        [Color(0xB237BB), Color(0xC93DEB), Color(0xB34CED), Color(0x9D5BE3), Color(0xBB93F8), Color(0xC6B2FF)],

        [Color(0x4C45FF), Color(0x2E57FF), Color(0x4D8DFF), Color(0x45BDFF), Color(0x6DDDFF), Color(0x65F4FF)],

        [Color(0xFE7E7E), Color(0xFF572E), Color(0xC22E2E), Color(0xA07753), Color(0xE3942E), Color(0xE8A753)],

        [Color(0xFF892E), Color(0xFFAB4C), Color(0xFFD166), Color(0xFFDE2E), Color(0xCFE855), Color(0xB9D32E)],

        [Color(0x105C08), Color(0x39972E), Color(0x3EDB67), Color(0x55E1B6), Color(0x69FFD0), Color(0x05C5C0)],
    ]
}
