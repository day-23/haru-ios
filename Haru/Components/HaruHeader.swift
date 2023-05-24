//
//  HaruHeader.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import SwiftUI

struct HaruHeader<
    HeaderBackground: View,
    Icon: View,
    Content: View
>: View {
    var toggleOn: Bool

    @Binding var toggleIsClicked: Bool
    @ViewBuilder var background: () -> HeaderBackground // 배경화면으로 보여질 화면을 추가한다.
    @ViewBuilder var icon: () -> Icon // 상단 오른쪽에 보여질 아이콘을 넘겨주면 된다.
    @ViewBuilder var view: () -> Content // 이동할 뷰를 넘겨주면 된다.

    init(
        toggleIsClicked: Binding<Bool>? = nil,
        @ViewBuilder background: @escaping () -> HeaderBackground = {
            LinearGradient(
                colors: [
                    Color(0xD2D7FF),
                    Color(0xAAD7FF),
                    Color(0xD2D7FF),
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .opacity(0.5)
        },
        @ViewBuilder icon: @escaping () -> Icon = {
            Image("magnifyingglass")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color(0x191919))
                .frame(width: 28, height: 28)
        },
        @ViewBuilder view: @escaping () -> Content
    ) {
        _toggleIsClicked = toggleIsClicked ?? .constant(false)
        self.background = background
        self.icon = icon
        self.view = view

        if toggleIsClicked == nil {
            toggleOn = false
        } else {
            toggleOn = true
        }
    }

    var body: some View {
        ZStack {
            background()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                HStack {
                    Image("logo")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))

                    if toggleOn {
                        Button {
                            withAnimation {
                                toggleIsClicked.toggle()
                            }
                        } label: {
                            Image("toggle")
                                .renderingMode(.template)
                                .foregroundColor(Color(0x646464))
                                .rotationEffect(.degrees(toggleIsClicked ? 90 : 0))
                        }
                    }

                    Spacer()
                    NavigationLink {
                        view()
                    } label: {
                        icon()
                    }
                }
                Spacer()
                    .frame(height: 20)
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
        }
        .frame(height: 52)
    }
}
