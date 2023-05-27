//
//  EmptySectionView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct EmptySectionView: View {
    var content: String = "모든 할 일을 마쳤습니다!"

    var body: some View {
        Text(content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.pretendard(size: 14, weight: .regular))
            .foregroundColor(Color(0x000000, opacity: 0.5))
            .padding(.vertical, 14)
    }
}
