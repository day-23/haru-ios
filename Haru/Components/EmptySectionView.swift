//
//  EmptySectionView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct EmptySectionView: View {
    var body: some View {
        Text("모든 할 일을 마쳤습니다!")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.footnote)
            .foregroundColor(Color(0x000000, opacity: 0.5))
            .padding(.leading, 34)
            .padding(.vertical)
    }
}
