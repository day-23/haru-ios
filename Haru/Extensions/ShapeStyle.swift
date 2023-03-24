//
//  ShapeStyle.swift
//  Haru
//
//  Created by 이준호 on 2023/03/17.
//

import Foundation
import SwiftUI

extension ShapeStyle where Self == Color {
    static var mainBlack: Color { Color("mainBlack") }
    static var gray1: Color { Color("gray1") }
    static var gray2: Color { Color("gray2") }
    static var gray3: Color { Color("gray3") }
    static var gray4: Color { Color("gray4") }

    static var error: Color { Color("error") }
    static var bg1: Color { Color("bg1") }
    static var bg2: Color { Color("bg2") }

    static var gradation1: Gradient {
        Gradient(colors: [Color("gradientStart1"), Color("gradientEnd1")])
    }

    static var gradation2: Gradient {
        Gradient(colors: [Color("gradientStart2"), Color("gradientEnd2")])
    }
}
