//
//  ListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct ListView<Content>: View where Content: View {
    @StateObject var checkListViewModel: CheckListViewModel
    @ViewBuilder let content: () -> Content
    let offsetChanged: (CGPoint?) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // 오늘 나의 하루와 12포인트만큼 간격 벌리기
                Spacer(minLength: 12)

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
            .onChange(of: checkListViewModel.todoListOffsetMap) { _ in
                guard let justAddedTodoId = checkListViewModel.justAddedTodoId
                else { return }
                withAnimation {
                    proxy.scrollTo(justAddedTodoId, anchor: .center)
                    checkListViewModel.justAddedTodoId = nil
                }
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
