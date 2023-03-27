//
//  MyToggleStyle.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import SwiftUI

struct MyToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack() {
            configuration.label
            Rectangle()
                .fill(configuration.isOn ? Gradient(colors: [.gradientStart2, .gradientEnd2]) : Gradient(colors: [.gray, .gray]))
                .frame(width: 38, height: 22, alignment: .center)
                .overlay(
                    Circle()
                        .strokeBorder(configuration.isOn ? Color.gradientStart2 : Color.gray, lineWidth: 1)
                        .background(Circle().fill(.white))
                        .offset(x: configuration.isOn ? 8 : -8, y: 0)
                )
                .cornerRadius(20)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
