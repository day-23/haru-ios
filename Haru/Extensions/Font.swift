//
//  Font.swift
//  Haru
//
//  Created by 이준호 on 2023/03/25.
//

import Foundation
import SwiftUI

extension Font {
    static func pretendard(size: CGFloat, weight: Font.Weight) -> Font {
        switch weight {
        case .regular:
            return Font.custom("Pretendard-Regular", size: size)
        case .medium:
            return Font.custom("Pretendard-Medium", size: size)
        case .semibold:
            return Font.custom("Pretendard-SemiBold", size: size)
        case .thin:
            return Font.custom("Pretendard-Thin", size: size)
        case .light:
            return Font.custom("Pretendard-Light", size: size)
        case .ultraLight:
            return Font.custom("Pretendard-ExtraLight", size: size)
        case .heavy:
            return Font.custom("Pretendard-ExtraBold", size: size)
        case .bold:
            return Font.custom("Pretendard-Bold", size: size)
        case .black:
            return Font.custom("Pretendard-Black", size: size)
        default:
            return Font.custom("Pretendard-Regular", size: size)
        }
    }
}
