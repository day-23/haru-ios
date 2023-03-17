//
//  Color.swift
//  Haru
//
//  Created by 최정민 on 2023/03/05.
//  Updated by 이준호 on 2023/03/17.
//

import Foundation
import SwiftUI

extension Color {
    // 하루 컬러
    static let mainBlack = Color("mainBlack")

    static let gray1 = Color("gray1")
    static let gray2 = Color("gray2")
    static let gray3 = Color("gray3")
    static let gray4 = Color("gray4")

    static let gradientStart1 = Color("gradientStart1")
    static let gradientEnd1 = Color("gradientEnd1")
    static let gradientStart2 = Color("gradientStart2")
    static let gradientEnd2 = Color("gradientEnd2")

    static let error = Color("error")
    static let bg1 = Color("bg1")
    static let bg2 = Color("bg2")

    init(_ hex: Int, opacity: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }

    init(_ hexString: String?, _ isCategory: Bool, opacity: Double = 1) {
        if let hexString, let hex = Int(hexString.suffix(6), radix: 16) {
            self.init(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                opacity: opacity
            )
        } else {
            self.init(
                red: CGFloat(170) / 255.0,
                green: CGFloat(215) / 255.0,
                blue: CGFloat(255) / 255.0,
                opacity: opacity
            )
        }
    }

    // for test
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
