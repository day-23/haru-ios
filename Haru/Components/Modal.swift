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
        self.ratio = ratio < 0.55 ? 0.55 : ratio
        self.content = content
    }

    var body: some View {
        ZStack {
            if isActive {
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: 50, height: 7)
                        .padding()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 50)
                        .foregroundColor(Color(0x33333F))
                    content()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .offset(y: UIScreen.main.bounds.height * (1 - ratio) + modalOffset.height)
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
                                if value.translation.height > UIScreen.main.bounds.height * 0.4 {
                                    isActive = false
                                }
                                modalOffset = .zero
                            }
                        }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
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
