//
//  Modal.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct Modal<Content>: View where Content: View {
    @Binding var isActive: Bool
    @State private var modalOffset = CGSize.zero
    var content: () -> Content

    @inlinable public init(isActive: Binding<Bool>, @ViewBuilder _ content: @escaping () -> Content) {
        _isActive = isActive
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
                .offset(y: UIScreen.main.bounds.height * 0.25 + modalOffset.height)
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
                                if value.translation.height > UIScreen.main.bounds.height * 0.25 {
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