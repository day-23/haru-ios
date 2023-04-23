//
//  ListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct ListView<Content>: View where Content: View {
    @ViewBuilder let content: () -> Content
    let offsetChanged: (CGPoint?) -> Void

    var body: some View {
        ScrollView {
            ZStack {
                //  LazyVStack {
                VStack {
                    content()

                    Spacer(minLength: 80)
                }

                GeometryReader { geometry in
                    Color.clear.preference(
                        key: OffsetKey.self,
                        value: geometry.frame(in: .named("scroll")).origin
                    )
                    .frame(height: 0)
                }
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(OffsetKey.self) { value in
            DispatchQueue.main.async {
                offsetChanged(value)
            }
        }
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGPoint? = nil
    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = value ?? nextValue()
    }
}
