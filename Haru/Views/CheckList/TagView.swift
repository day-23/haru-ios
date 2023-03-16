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
            .bold()
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(0xFEFEFE))
            .cornerRadius(10)
            .shadow(color: Color(0x000000, opacity: 0.7), radius: 0.5)
    }
}
