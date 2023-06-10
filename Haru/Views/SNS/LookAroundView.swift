//
//  LookAroundView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct LookAroundView: View {
    var body: some View {
        VStack(spacing: 0) {
            MediaListView(postVM: PostViewModel(option: .media))
        }
    }
}
