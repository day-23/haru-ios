//
//  CustomToggleStyle.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Rectangle()
                .fill(configuration.isOn
                    ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(0xDBDBDB)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 38, height: 18, alignment: .center)
                .overlay(
                    Circle()
                        .strokeBorder(configuration.isOn
                            ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color(0xDBDBDB)], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 1)
                        .background(Circle().fill(Color(0xFDFDFD)))
                        .offset(x: configuration.isOn ? 10 : -10, y: 0)
                )
                .cornerRadius(20)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
