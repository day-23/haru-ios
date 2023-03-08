//
//  Modal.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct Modal<Content>: View where Content: View {
    @State private var modalOffset = CGSize.zero
    @Binding var isActive: Bool
    var ratio: CGFloat
    var content: () -> Content

    @inlinable public init(isActive: Binding<Bool>, ratio: CGFloat, @ViewBuilder _ content: @escaping () -> Content) {
        _isActive = isActive
        self.ratio = max(ratio, 0.2)
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy1 in
            ZStack {
                if isActive {
                    VStack {
                        RoundedRectangle(cornerRadius: 50)
                            .frame(width: 50, height: 7)
                            .padding()
                            .foregroundColor(Color(0x33333F))
                        content()
                            .padding(.bottom)
                            .padding(.bottom, 17)
                    }
                    .frame(maxWidth: .infinity, minHeight: proxy1.size.height * ratio + 40, maxHeight: proxy1.size.height * ratio + 40)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .position(x: proxy1.size.width * 0.5, y: proxy1.size.height * (1 - ratio) + modalOffset.height + (proxy1.size.height * ratio) * 0.5)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.startLocation.y - value.location.y > 0 {
                                    return
                                }
                                modalOffset = value.translation
                            }
                            .onEnded { value in
                                withAnimation {
                                    if value.translation.height > proxy1.size.height * 0.5 {
                                        isActive = false
                                    }
                                    modalOffset = .zero
                                }
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .onDisappear {
                        modalOffset = .zero
                    }
                }
            }
            .onAppear {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
