//
//  Color.swift
//  Haru
//
//  Created by 최정민 on 2023/03/05.
//

import Foundation
import SwiftUI

extension Color {
    init(_ hex: Int, opacity: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
    
    // for test
    static var random: Color {
            return Color(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1)
            )
        }
}
