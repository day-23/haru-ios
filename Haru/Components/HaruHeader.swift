//
//  HaruHeader.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import SwiftUI

struct HaruHeader<
    HeaderBackground: View,
    HeaderItem: View
>: View {
    var toggleOn: Bool

    @Binding var toggleIsClicked: Bool
    @ViewBuilder var background: () -> HeaderBackground // 배경화면으로 보여질 화면을 추가한다.
    @ViewBuilder var item: () -> HeaderItem // 헤더 오른쪽에 들어갈 아이템을 정의한다.

    init(
        toggleIsClicked: Binding<Bool>? = nil,
        @ViewBuilder background: @escaping () -> HeaderBackground = {
            Image("background-gradation")
                .resizable()
        },

        @ViewBuilder item: @escaping () -> HeaderItem
    ) {
        _toggleIsClicked = toggleIsClicked ?? .constant(false)
        self.background = background
        self.item = item

        if toggleIsClicked == nil {
            self.toggleOn = false
        } else {
            self.toggleOn = true
        }
    }

    var body: some View {
        ZStack {
            self.background()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                HStack {
                    Image("logo")

                    if self.toggleOn {
                        Button {
                            withAnimation {
                                self.toggleIsClicked.toggle()
                            }
                        } label: {
                            Image("todo-toggle")
                                .renderingMode(.template)
                                .foregroundColor(Color(0xFDFDFD))
                                .rotationEffect(.degrees(self.toggleIsClicked ? 90 : 0))
                        }
                    }

                    Spacer()

                    self.item()
                }
                Spacer()
                    .frame(height: 20)
            }
            .padding(.top, 10)
            .padding(.leading, 25)
            .padding(.trailing, 20)
        }
        .frame(height: 52)
    }
}
