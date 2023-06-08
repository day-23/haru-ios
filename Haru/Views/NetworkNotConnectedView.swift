//
//  NetworkNotConnectedView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/09.
//

import SwiftUI

struct NetworkNotConnectedView: View {
    var body: some View {
        ZStack {
            Image("background-main-splash")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            Image("network-not-connected")

            Text("인터넷 연결을 확인해주세요.")
                .font(.pretendard(size: 16, weight: .bold))
                .foregroundColor(Color(0x1DAFFF))
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color(0xFDFDFD, opacity: 0.5))
                .cornerRadius(10)
                .offset(y: UIScreen.main.bounds.height * 0.3)
        }
    }
}

struct NetworkNotConnected_Previews: PreviewProvider {
    static var previews: some View {
        NetworkNotConnectedView()
    }
}
