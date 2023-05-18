//
//  HashTagView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/18.
//

import SwiftUI

struct HashTagView: View {
    @StateObject var postVM: PostViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(postVM.hashTags.indices, id: \.self) { idx in
                    Text(postVM.hashTags[idx].content)
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(
                            postVM.hashTags[idx] == postVM.selectedHashTag
                                ? .white
                                : Color(0x191919)
                        )
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            postVM.hashTags[idx] == postVM.selectedHashTag
                                ? LinearGradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color(0xFDFDFD)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Gradient(colors: [Color(0xD2D7FF), Color(0xAAD7FF)]),
                                    lineWidth: 1
                                )
                        )
                        .onTapGesture {
                            postVM.selectedHashTag = postVM.hashTags[idx]
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}
