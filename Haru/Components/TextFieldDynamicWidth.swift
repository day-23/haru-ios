//
//  TextFieldDynamicWidth.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import SwiftUI

struct TextFieldDynamicWidth: View {
    let title: String
    @Binding var text: String
    @Binding var textRect: CGRect
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void

    var body: some View {
        ZStack {
            Text(text == "" ? title : text).background(GlobalGeometryGetter(rect: $textRect)).layoutPriority(1).opacity(0)
            HStack {
                TextField(title, text: $text, axis: .vertical)
                    .lineLimit(4)
                    .frame(width: textRect.width)
                    .frame(maxWidth: 50)
            }
        }
    }
}

struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}
