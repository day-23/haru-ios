//
//  MyView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/24.
//

import SwiftUI

struct MyView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader(icon: {
                    Image("setting")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                        .frame(width: 28, height: 28)
                }, view: {
                    // Setting View
                })

                ScrollView {
                    VStack(spacing: 0) {}
                }
            }
        }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
    }
}
