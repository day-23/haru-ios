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
            return Font.custom("Pretendard-Regular", fixedSize: size)
        case .medium:
            return Font.custom("Pretendard-Medium", fixedSize: size)
        case .semibold:
            return Font.custom("Pretendard-SemiBold", fixedSize: size)
        case .thin:
            return Font.custom("Pretendard-Thin", fixedSize: size)
        case .light:
            return Font.custom("Pretendard-Light", fixedSize: size)
        case .ultraLight:
            return Font.custom("Pretendard-ExtraLight", fixedSize: size)
        case .heavy:
            return Font.custom("Pretendard-ExtraBold", fixedSize: size)
        case .bold:
            return Font.custom("Pretendard-Bold", fixedSize: size)
        case .black:
            return Font.custom("Pretendard-Black", fixedSize: size)
        default:
            return Font.custom("Pretendard-Regular", fixedSize: size)
        }
    }
}
