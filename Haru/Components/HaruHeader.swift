//
//  HaruHeader.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import SwiftUI

struct HaruHeader<
    HeaderItem: View
>: View {
    var toggleOn: Bool

    @Binding var toggleIsClicked: Bool
    @ViewBuilder var item: () -> HeaderItem // 헤더 오른쪽에 들어갈 아이템을 정의한다.

    init(
        toggleIsClicked: Binding<Bool>? = nil,
        @ViewBuilder item: @escaping () -> HeaderItem
    ) {
        _toggleIsClicked = toggleIsClicked ?? .constant(false)
        self.item = item

        if toggleIsClicked == nil {
            self.toggleOn = false
        } else {
            self.toggleOn = true
        }
    }

    var body: some View {
        ZStack {
            Color.white
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
                                .foregroundColor(Color(0x646464))
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
