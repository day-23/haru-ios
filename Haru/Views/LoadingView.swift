//
//  LoadingView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/09.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("로딩 중입니다")
                .font(.pretendard(size: 16, weight: .bold))
                .foregroundColor(Color(0x1DAFFF))
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color(0xDBDBDB))
                .cornerRadius(10)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
