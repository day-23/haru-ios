//
//  SplashView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/19.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Image("background-main")
            .overlay {
                VStack(spacing: 0) {
                    Image("haru")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color(0xffffff))
                        .frame(width: 400, height: 57)
                    Image("character-main")
                }
            }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
