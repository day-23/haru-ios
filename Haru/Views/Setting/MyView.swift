//
//  MyView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/24.
//

import SwiftUI

struct MyView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader {
                    NavigationLink {
                        SettingView(isLoggedIn: $isLoggedIn)
                    } label: {
                        Image("setting")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                }

                ScrollView {
                    VStack(spacing: 0) {}
                }
            }
        }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView(
            isLoggedIn: .constant(false)
        )
    }
}
