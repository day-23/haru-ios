//
//  ListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct ListView<Content>: View where Content: View {
    @ViewBuilder let content: () -> Content
    let offsetChanged: (CGFloat?) -> Void

    var body: some View {
        ScrollView {
            LazyVStack {
                content()
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: OffsetKey.self,
                        value: geometry.frame(in: .global).minY
                    )
                    .frame(height: 0)
                }
            }
        }
        .onPreferenceChange(OffsetKey.self) { offsetChanged($0) }
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}
