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
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                content()
            }

            GeometryReader { geometry in
                Color.clear.preference(
                    key: OffsetKey.self,
                    value: geometry.frame(in: .global).minY
                )
                .frame(height: 0)
            }
        }
        .onPreferenceChange(OffsetKey.self) { value in
            DispatchQueue.main.async {
                offsetChanged(value)
            }
        }
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}
