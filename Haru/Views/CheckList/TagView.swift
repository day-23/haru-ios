//
//  TagView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TagView: View {
    var tag: Tag
    var fontSize: CGFloat = 16
    var isSelected: Bool = false
    var disabled: Bool = false

    var body: some View {
        Text(tag.content)
            .font(.pretendard(size: fontSize, weight: .bold))
            .foregroundColor(
                isSelected || disabled
                    ? .white
                    : Color(0x191919)
            )
            .bold()
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                disabled
                    ? LinearGradient(colors: [Color(0xDBDBDB)], startPoint: .leading, endPoint: .leading)
                    : (isSelected
                        ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color(0xFDFDFD)], startPoint: .leading, endPoint: .trailing))
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Gradient(
                            colors: !disabled
                                ? [Color(0xD2D7FF), Color(0xAAD7FF)]
                                : [.clear]
                        ),
                        lineWidth: 1
                    )
            )
            .padding(.vertical, 1)
    }
}
