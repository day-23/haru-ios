//
//  TagView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TagView: View {
    var tag: Tag
    init(_ tag: Tag) {
        self.tag = tag
    }

    var body: some View {
        Text(tag.content)
            .font(.caption)
            .foregroundColor(.black)
            .bold()
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(0xFDFDFD))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]), lineWidth: 1)
            )
    }
}
